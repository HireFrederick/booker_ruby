require 'rubygems'

require 'shoulda/matchers'
require 'booker_ruby'
require 'carmen'

Time.zone = 'UTC'

Booker.config[:log_message] = -> (message, extra_info) { true }

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

