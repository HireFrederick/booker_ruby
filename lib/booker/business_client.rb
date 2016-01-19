module Booker
  class BusinessClient < Client
    include Booker::BusinessREST

    attr_accessor :booker_account_name, :booker_username, :booker_password

    def initialize(options={})
      self.base_url = ENV['BOOKER_BUSINESS_SERVICE_URL'] || 'https://apicurrent-app.booker.ninja/webservice4/json/BusinessService.svc'
      super
    end

    def get_access_token
      http_options = {
        client_id: self.client_id,
        client_secret: self.client_secret,
        'AccountName' => self.booker_account_name,
        'UserName' => self.booker_username,
        'Password' => self.booker_password
      }
      response = post('/accountlogin', http_options, nil).parsed_response

      raise Booker::InvalidApiCredentials.new(http_options, response) unless response.present?

      self.temp_access_token_expires_at = Time.now + response['expires_in'].to_i.seconds
      self.temp_access_token = response['access_token']

      update_token_store

      self.temp_access_token
    end
  end
end
