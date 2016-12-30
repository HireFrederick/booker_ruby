module Booker
  class Client
    attr_accessor :base_url, :client_id, :client_secret, :temp_access_token, :temp_access_token_expires_at,
                  :token_store, :token_store_callback_method

    ACCESS_TOKEN_HTTP_METHOD = :get
    ACCESS_TOKEN_ENDPOINT = '/access_token'.freeze
    BOOKER_SERVER_TIMEZONE = 'Eastern Time (US & Canada)'.freeze
    DEFAULT_CONTENT_TYPE = 'application/json; charset=utf-8'.freeze

    def initialize(options = {})
      options.each { |key, value| send(:"#{key}=", value) }
      self.base_url ||= get_base_url
      self.client_id ||= ENV['BOOKER_CLIENT_ID']
      self.client_secret ||= ENV['BOOKER_CLIENT_SECRET']
    end

    def get_base_url
      env_key = try(:env_base_url_key)

      if env_key.present?
        ENV[env_key] || try(:default_base_url)
      else
        try(:default_base_url)
      end
    end

    def get(path, params, booker_model=nil)
      booker_resources = get_booker_resources(:get, path, params, nil, booker_model)

      build_resources(booker_resources, booker_model)
    end

    def post(path, data, booker_model=nil)
      booker_resources = get_booker_resources(:post, path, nil, data.to_json, booker_model)

      build_resources(booker_resources, booker_model)
    end

    def put(path, data, booker_model=nil)
      booker_resources = get_booker_resources(:put, path, nil, data.to_json, booker_model)

      build_resources(booker_resources, booker_model)
    end

    def paginated_request(method:, path:, params:, model: nil, fetched: [], fetch_all: true)
      page_size = params['PageSize']
      page_number = params['PageNumber']

      if page_size.nil? || page_size < 1 || page_number.nil? || page_number < 1 || !params['UsePaging']
        raise ArgumentError, 'params must include valid PageSize, PageNumber and UsePaging'
      end

      puts "fetching #{path} with #{params.except('access_token')}. #{fetched.length} results so far."

      results = self.send(method, path, params, model)

      unless results.is_a?(Array)
        raise StandardError, "Result from paginated request to #{path} with params: #{params} is not a collection"
      end

      fetched.concat(results)
      results_length = results.length

      if fetch_all
        if results_length > 0
          # TODO (#111186744): Add logging to see if any pages with less than expected data (as seen in the /appointments endpoint)
          new_params = params.deep_dup
          new_params['PageNumber'] = page_number + 1
          paginated_request(method: method, path: path, params: new_params, model: model, fetched: fetched)
        else
          fetched
        end
      else
        results
      end
    end

    def get_booker_resources(http_method, path, params=nil, body=nil, booker_model=nil)
      http_options = request_options(params, body)
      url = full_url(path)
      puts "BOOKER REQUEST: #{http_method} #{url} #{http_options}" if ENV['BOOKER_API_DEBUG'] == 'true'

      # Allow it to retry the first time unless it is an authorization error
      begin
        response = handle_errors!(url, http_options, HTTParty.send(http_method, url, http_options))
      rescue Booker::Error, Net::ReadTimeout => ex
        if ex.is_a? Booker::InvalidApiCredentials
          raise ex
        else
          sleep 1
          response = nil # Force a retry (see logic below)
        end
      end

      unless response.nil? || nil_or_empty_hash?(response.parsed_response)
        return results_from_response(response, booker_model)
      end

      # Retry on blank responses (happens in certain v4 API methods in lieu of an actual error)
      response = handle_errors!(url, http_options, HTTParty.send(http_method, url, http_options))
      unless response.nil? || nil_or_empty_hash?(response.parsed_response)
        return results_from_response(response, booker_model)
      end

      # Raise if response is still blank
      raise Booker::Error.new(url: url, request: http_options, response: response)
    end

    def full_url(path)
      uri = URI(path)
      uri.scheme ? path : "#{self.base_url}#{path}"
    end

    def handle_errors!(url, request, response)
      puts "BOOKER RESPONSE: #{response}" if ENV['BOOKER_API_DEBUG'] == 'true'

      ex = Booker::Error.new(url: url, request: request, response: response)
      if ex.error.present? || !response.success?
        case ex.error
          when 'invalid_client'
            raise Booker::InvalidApiCredentials.new(url: url, request: request, response: response)
          when 'invalid access token'
            get_access_token
            return nil
          else
            raise ex
        end
      end

      response
    end

    def access_token
      (self.temp_access_token && !temp_access_token_expired?) ? self.temp_access_token : get_access_token
    end

    def access_token_options
      {
          client_id: self.client_id,
          client_secret: self.client_secret
      }
    end

    def update_token_store
      if self.token_store.present? && self.token_store_callback_method.present?
        self.token_store.send(self.token_store_callback_method, self.temp_access_token, self.temp_access_token_expires_at)
      end
    end

    def get_access_token
      http_options = access_token_options
      token_data = raise_invalid_api_credentials_for_empty_resp!{ access_token_response(http_options) }

      self.temp_access_token_expires_at = Time.now + token_data['expires_in'].to_i.seconds
      self.temp_access_token = token_data['access_token']

      update_token_store

      self.temp_access_token
    end

    def raise_invalid_api_credentials_for_empty_resp!
      yield
    rescue Booker::Error => ex
      if ex.response && ex.response.parsed_response.present?
        raise ex
      else
        raise Booker::InvalidApiCredentials.new(url: ex.url, request: ex.request, response: ex.response)
      end
    end

    def access_token_response(http_options)
      send(self.class::ACCESS_TOKEN_HTTP_METHOD, self.class::ACCESS_TOKEN_ENDPOINT, http_options, nil)
    end

    private
      def request_options(query=nil, body=nil)
        options = {
          headers: {
            'Content-Type': DEFAULT_CONTENT_TYPE
          },
          open_timeout: 120
        }

        options[:body] = body if body.present?
        options[:query] = query if query.present?
        options
      end

      def build_resources(resources, booker_model)
        return resources if booker_model.nil?

        if resources.is_a? Hash
          booker_model.from_hash(resources)
        elsif resources.is_a? Array
          booker_model.from_list(resources)
        else
          resources
        end
      end

      def temp_access_token_expired?
        self.temp_access_token_expires_at.nil? || self.temp_access_token_expires_at <= Time.now
      end

      def results_from_response(response, booker_model=nil)
        parsed_response = response.parsed_response

        return parsed_response unless parsed_response.is_a?(Hash)
        return parsed_response['Results'] unless parsed_response['Results'].nil?

        if booker_model
          model_name = booker_model.to_s.demodulize
          return parsed_response[model_name] unless parsed_response[model_name].nil?

          pluralized = model_name.pluralize
          return parsed_response[pluralized] unless parsed_response[pluralized].nil?
        end

        parsed_response
      end

      def nil_or_empty_hash?(obj)
        obj.nil? || (obj.is_a?(Hash) && obj.blank?)
      end
  end
end
