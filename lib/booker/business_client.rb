module Booker
  class BusinessClient < Client
    include Booker::BusinessREST

    attr_accessor :booker_account_name, :booker_username, :booker_password

    def env_base_url_key; 'BOOKER_BUSINESS_SERVICE_URL'; end

    def default_base_url; 'https://apicurrent-app.booker.ninja/webservice4/json/BusinessService.svc'; end

    def access_token_endpoint; '/accountlogin'; end

    def access_token_http_method; :post; end

    def access_token_options
      super.merge!(
          'AccountName' => self.booker_account_name,
          'UserName' => self.booker_username,
          'Password' => self.booker_password
      )
    end
  end
end
