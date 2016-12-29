module Booker
  module V5
    class Client < Booker::Client
      attr_accessor :api_subscription_key, :access_token_scope, :location_id

      CREATE_TOKEN_CONTENT_TYPE = 'application/x-www-form-urlencoded'.freeze
      CREATE_TOKEN_GRANT_TYPE = 'client_credentials'.freeze
      CREATE_TOKEN_PATH = '/v5/auth/connect/token'.freeze
      ENV_BASE_URL_KEY = 'BOOKER_API_BASE_URL'.freeze
      DEFAULT_BASE_URL = 'https://api-staging.booker.com'.freeze
      VALID_ACCESS_TOKEN_SCOPES = %w(public merchant parter-payment internal).map(&:freeze).freeze
      API_GATEWAY_ERRORS = {
        503 => Booker::ServiceUnavailable,
        504 => Booker::ServiceUnavailable,
        429 => Booker::RateLimitExceeded,
        401 => Booker::InvalidApiCredentials,
        403 => Booker::InvalidApiCredentials
      }.freeze

      def initialize(options = {})
        options[:api_subscription_key] ||= ENV['BOOKER_API_SUBSCRIPTION_KEY']
        if options[:access_token_scope].blank?
          options[:access_token_scope] = options[:location_id].present? ? 'merchant' : 'public'
        elsif !options[:access_token_scope].in?(VALID_ACCESS_TOKEN_SCOPES)
          raise ArgumentError, "access_token_scope must be one of: #{VALID_ACCESS_TOKEN_SCOPES.join(', ')}"
        end

        super
      end

      def env_base_url_key; ENV_BASE_URL_KEY; end

      def default_base_url; DEFAULT_BASE_URL; end

      def get_access_token
        token_data = access_token_response.parsed_response
        self.temp_access_token_expires_at = Time.now + token_data['expires_in'].to_i.seconds
        token = token_data['access_token']

        if self.location_id
          self.temp_access_token = get_location_access_token(token, self.location_id)
        else
          self.temp_access_token = token
        end

        update_token_store

        self.temp_access_token
      end

      def access_token_response
        options = {
          headers: {
            'Content-Type': CREATE_TOKEN_CONTENT_TYPE,
            'Ocp-Apim-Subscription-Key': self.api_subscription_key
          },
          body: {
            grant_type: CREATE_TOKEN_GRANT_TYPE,
            client_id: self.client_id,
            client_secret: self.client_secret,
            scope: self.access_token_scope
          }.to_query
        }

        url = full_url(CREATE_TOKEN_PATH)

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
            'Ocp-Apim-Subscription-Key': self.api_subscription_key,
            'Authorization': "Bearer #{existing_token}"
          },
          query: {
            locationId: location_id
          }
        }
        url = full_url('/v5/auth/context/update')

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

        def handle_errors!(url, request, response)
          error_class = API_GATEWAY_ERRORS[response.code]
          raise error_class.new(url: url, request: request, response: response) if error_class
          super
        end

        def request_options(query=nil, body=nil)
          options = super
          options[:headers].merge!(
            Authorization: "Bearer #{access_token}",
            'Ocp-Apim-Subscription-Key': self.api_subscription_key
          )
          options
        end
    end
  end
end
