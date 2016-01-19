module Booker
  class CustomerClient < Client
    include Booker::CustomerREST

    def initialize(options={})
      self.base_url = ENV['BOOKER_CUSTOMER_SERVICE_URL'] || 'https://apicurrent-app.booker.ninja/webservice4/json/CustomerService.svc'
      self.token_store = GenericTokenStore
      self.token_store_callback_method = :update_booker_access_token!
      super
    end

    def get_access_token
      http_options = {
        client_id: self.client_id,
        client_secret: self.client_secret,
        grant_type: 'client_credentials'
      }

      response = get("/access_token", http_options, nil).parsed_response

      raise Booker::InvalidApiCredentials.new(http_options, response) unless response.present?

      self.temp_access_token_expires_at = Time.now + response['expires_in'].to_i.seconds
      self.temp_access_token = response['access_token']

      update_token_store

      self.temp_access_token
    end
  end
end
