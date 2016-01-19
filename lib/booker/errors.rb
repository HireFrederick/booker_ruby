module Booker
  class Error < StandardError
    attr_accessor :error, :description, :request, :response

    def initialize(request = nil, response = nil)
      if request.present?
        self.request = request
      end

      if response.present?
        self.response = response
        self.error = response['error'] || response['ErrorMessage']
        self.description = response['error_description']
      end
    end
  end

  class InvalidApiCredentials < Error; end
end
