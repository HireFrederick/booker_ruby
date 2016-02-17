module Booker
  class CustomerClient < Client
    include Booker::CustomerREST

    def initialize(options={})
      super
      self.token_store ||= GenericTokenStore
      self.token_store_callback_method ||= :update_booker_access_token!
    end

    def env_base_url_key; 'BOOKER_CUSTOMER_SERVICE_URL'; end

    def default_base_url; 'https://apicurrent-app.booker.ninja/webservice4/json/CustomerService.svc'; end

    def access_token_options; super.merge!(grant_type: 'client_credentials'); end
  end
end
