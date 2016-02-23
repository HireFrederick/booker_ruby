module Booker
  module Helpers
    module LoggingHelper
      def self.log_issue(message, extra_info = {})
        if (log_message_block = Booker.config[:log_message])
          log_message_block.call(message, extra_info)
        end
      end
    end
  end
end
