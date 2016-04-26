module Booker
  class Error < StandardError
    attr_accessor :error, :description, :url, :request, :response

    def initialize(url: nil, request: nil, response: nil)
      if request.present?
        self.request = request
      end

      if response.present?
        self.response = response
        self.error = response['error'] || response['ErrorMessage']
        self.description = response['error_description']
      end

      self.url = url
    end
  end

  class InvalidApiCredentials < Error; end
end
