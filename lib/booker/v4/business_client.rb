module Booker
  module V4
    class BusinessClient < Booker::Client
      include Booker::V4::BusinessREST
      ENV_BASE_URL_KEY = 'BOOKER_BUSINESS_SERVICE_URL'.freeze
      DEFAULT_BASE_URL = 'https://apicurrent-app.booker.ninja/webservice4/json/BusinessService.svc'.freeze
    end
  end
end
