module Booker
  class Client
    attr_accessor :base_url, :auth_base_url, :client_id, :client_secret, :temp_access_token,
                  :temp_access_token_expires_at, :token_store, :token_store_callback_method, :api_subscription_key,
                  :access_token_scope, :refresh_token, :location_id, :auth_with_client_credentials

    CREATE_TOKEN_CONTENT_TYPE = 'application/x-www-form-urlencoded'.freeze
    CLIENT_CREDENTIALS_GRANT_TYPE = 'client_credentials'.freeze
    REFRESH_TOKEN_GRANT_TYPE = 'refresh_token'.freeze
    CREATE_TOKEN_PATH = '/v5/auth/connect/token'.freeze
    UPDATE_TOKEN_CONTEXT_PATH = '/v5/auth/context/update'.freeze
    VALID_ACCESS_TOKEN_SCOPES = %w(public merchant parter-payment internal).map(&:freeze).freeze
    API_GATEWAY_ERRORS = {
      503 => Booker::ServiceUnavailable,
      504 => Booker::ServiceUnavailable,
      429 => Booker::RateLimitExceeded,
      401 => Booker::InvalidApiCredentials,
      403 => Booker::InvalidApiCredentials
    }.freeze
    BOOKER_SERVER_TIMEZONE = 'Eastern Time (US & Canada)'.freeze
    DEFAULT_CONTENT_TYPE = 'application/json'.freeze
    ENV_BASE_URL_KEY = 'BOOKER_API_BASE_URL'.freeze
    DEFAULT_BASE_URL = 'https://api-staging.booker.com'.freeze
    DEFAULT_AUTH_BASE_URL = 'https://api-staging.booker.com'

    def initialize(options = {})
      options.each { |key, value| send(:"#{key}=", value) }
      self.base_url ||= get_base_url
      self.auth_base_url ||= ENV['BOOKER_API_BASE_URL'] || DEFAULT_AUTH_BASE_URL
      self.client_id ||= ENV['BOOKER_CLIENT_ID']
      self.client_secret ||= ENV['BOOKER_CLIENT_SECRET']
      self.api_subscription_key ||= ENV['BOOKER_API_SUBSCRIPTION_KEY']
      if self.auth_with_client_credentials.nil?
        self.auth_with_client_credentials = ENV['BOOKER_API_AUTH_WITH_CLIENT_CREDENTIALS'] == 'true'
      end
      if self.temp_access_token.present?
        begin
          self.temp_access_token_expires_at = token_expires_at(self.temp_access_token)
          self.access_token_scope = token_scope(self.temp_access_token)
        rescue JWT::ExpiredSignature => ex
          raise ex unless self.auth_with_client_credentials || self.refresh_token.present?
        end
      end
      if self.access_token_scope.blank?
        self.access_token_scope = VALID_ACCESS_TOKEN_SCOPES.first
      elsif !self.access_token_scope.in?(VALID_ACCESS_TOKEN_SCOPES)
        raise ArgumentError, "access_token_scope must be one of: #{VALID_ACCESS_TOKEN_SCOPES.join(', ')}"
      end
    end

    def get_base_url
      ENV[self.class::ENV_BASE_URL_KEY] || self.class::DEFAULT_BASE_URL
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

    def delete(path, params=nil, body=nil, booker_model=nil)
      booker_resources = get_booker_resources(:delete, path, params, body.to_json, booker_model)

      build_resources(booker_resources, booker_model)
    end

    def paginated_request(method:, path:, params:, model: nil, fetched: [], fetch_all: true)
      page_size = params[:PageSize]
      page_number = params[:PageNumber]

      if page_size.nil? || page_size < 1 || page_number.nil? || page_number < 1 || !params[:UsePaging]
        raise ArgumentError, 'params must include valid PageSize, PageNumber and UsePaging'
      end

      puts "fetching #{path} with #{params.except(:access_token)}. #{fetched.length} results so far."

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
          new_params[:PageNumber] = page_number + 1
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

      error_class = API_GATEWAY_ERRORS[response.code]
      raise error_class.new(url: url, request: request, response: response) if error_class

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

    def update_token_store
      if self.token_store.present? && self.token_store_callback_method.present?
        self.token_store.send(self.token_store_callback_method, self.temp_access_token, self.temp_access_token_expires_at)
      end
    end

    def get_access_token
      unless self.auth_with_client_credentials || self.refresh_token
        raise ArgumentError, 'Cannot get new access token without auth_with_client_credentials or a refresh_token'
      end

      resp = access_token_response
      token = resp.parsed_response['access_token']
      raise Booker::InvalidApiCredentials.new(response: resp) if token.blank?

      if self.auth_with_client_credentials && self.location_id
        self.temp_access_token = get_location_access_token(token, self.location_id)
      else
        self.temp_access_token = token
      end

      self.temp_access_token_expires_at = token_expires_at(self.temp_access_token)

      update_token_store

      self.temp_access_token
    end

    def access_token_response
      body = {
        grant_type: self.auth_with_client_credentials ? CLIENT_CREDENTIALS_GRANT_TYPE : REFRESH_TOKEN_GRANT_TYPE,
        client_id: self.client_id,
        client_secret: self.client_secret,
        scope: self.access_token_scope
      }
      body[:refresh_token] = self.refresh_token if body[:grant_type] == REFRESH_TOKEN_GRANT_TYPE
      options = {
        headers: {
          'Content-Type' => CREATE_TOKEN_CONTENT_TYPE,
          'Ocp-Apim-Subscription-Key' => self.api_subscription_key
        },
        body: body.to_query,
        timeout: 30
      }

      url = "#{self.auth_base_url}#{CREATE_TOKEN_PATH}"

      begin
        handle_errors! url, options, HTTParty.post(url, options)
      rescue Booker::ServiceUnavailable, Booker::RateLimitExceeded
        # retry once
        sleep 1
        handle_errors! url, options, HTTParty.post(url, options)
      end
    end

    def get_location_access_token(existing_token, location_id)
      options = {
        headers: {
          'Accept' => 'application/json',
          'Authorization' => "Bearer #{existing_token}",
          'Ocp-Apim-Subscription-Key' => self.api_subscription_key
        },
        query: {
          locationId: location_id
        },
        timeout: 30
      }
      url = "#{self.auth_base_url}#{UPDATE_TOKEN_CONTEXT_PATH}"

      begin
        resp = handle_errors! url, options, HTTParty.post(url, options)
      rescue Booker::ServiceUnavailable, Booker::RateLimitExceeded
        # retry once
        sleep 1
        resp = handle_errors! url, options, HTTParty.post(url, options)
      end

      resp.parsed_response
    end

    private
      def request_options(query=nil, body=nil)
        options = {
          # Headers must use stringified keys due to how they are transformed in some Net::HTTP versions
          headers: {
            'Content-Type' => DEFAULT_CONTENT_TYPE,
            'Accept' => DEFAULT_CONTENT_TYPE,
            'Authorization' => "Bearer #{access_token}",
            'Ocp-Apim-Subscription-Key' => self.api_subscription_key
          },
          open_timeout: 120,
          read_timeout: 300
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

      def token_expires_at(token)
        Time.at(decoded_token_info(token)['exp'])
      end

      def token_scope(token)
        decoded_token_info(token)['scope']
      end

      def decoded_token_info(token)
        JWT.decode(token, nil, false, verify_not_before: false)[0]
      end
  end
end
