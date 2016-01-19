module Booker
  class GenericTokenStore
    def self.temp_access_token
      @temp_access_token
    end

    def self.temp_access_token=(token)
      @temp_access_token = token
    end

    def self.temp_access_token_expires_at
      @temp_access_token_expires_at
    end

    def self.temp_access_token_expires_at=(expires_at)
      @temp_access_token_expires_at = expires_at
    end

    def self.update_booker_access_token!(token, expires_at)
      self.temp_access_token = token
      self.temp_access_token_expires_at = expires_at
      true
    end
  end
end
