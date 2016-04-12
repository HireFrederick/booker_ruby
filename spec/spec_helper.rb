require 'rubygems'

require 'shoulda/matchers'
require 'booker_ruby'
require 'carmen'

Time.zone = 'UTC'

Booker.config[:log_message] = -> (message, extra_info) { true }

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

class TestClient
  def self.booker_client_id; 'foo_client_id' ;end

  def self.booker_client_secret; 'foo_client_secret' ;end

  def self.business_client
    Booker::BusinessClient.new(
        client_id: booker_client_id,
        client_secret: booker_client_secret,
        booker_account_name: 'foo_account_name',
        booker_username: 'foo_username',
        booker_password: 'foo_password'
    )
  end

  def self.customer_client
    Booker::CustomerClient.new(
        client_id: booker_client_id,
        client_secret: booker_client_secret
    )
  end
end

