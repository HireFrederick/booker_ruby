module Booker
  module V4
    class CustomerClient < Client
      include Booker::V4::CustomerREST
      ENV_BASE_URL_KEY = 'BOOKER_CUSTOMER_SERVICE_URL'.freeze
      DEFAULT_BASE_URL = 'https://apicurrent-app.booker.ninja/webservice4/json/CustomerService.svc'.freeze

      def initialize(options={})
        super
        self.token_store ||= GenericTokenStore
        self.token_store_callback_method ||= :update_booker_access_token!
      end
    end
  end
end
