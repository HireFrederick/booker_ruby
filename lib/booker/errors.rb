module Booker
  class Error < StandardError
    attr_accessor :error, :description, :url, :request, :response

    def initialize(url: nil, request: nil, response: nil)
      if request.present?
        self.request = request
      end

      if response.present?
        self.response = response
        if response.parsed_response.is_a?(Hash)
          self.error = response.parsed_response['error'] || response.parsed_response['ErrorMessage']
          self.description = response.parsed_response['error_description']
        end
      end

      self.url = url
    end
  end

  class InvalidApiCredentials < Error; end
  class ServiceUnavailable < Error; end
  class RateLimitExceeded < Error; end
end
