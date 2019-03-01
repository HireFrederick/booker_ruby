module Booker
  module Concerns
    module DateTimeConcern
      # Booker's API hands you back all time as if the business is in server time.
      # First load the time in server time, then return the same hours and minutes in current time zone.
      def time_from_booker_datetime(booker_datetime)
        timestamp = booker_datetime[/\/Date\((.\d+)[\-\+]/, 1].to_i / 1000.to_f

        original_tz = Time.zone
        begin
          # Booker's server is always EST
          Time.zone = Booker::Client::BOOKER_SERVER_TIMEZONE

          booker_time = Time.zone.at(timestamp)
        ensure
          Time.zone = original_tz
        end

        # Convert it back to location time without changing hours and minutes
        Time.zone.parse(booker_time.strftime('%Y-%m-%d %H:%M:%S'))
      end

      # Booker's API requires times to be sent in as if the business is in Eastern Time!
      def time_to_booker_datetime(time)
        original_tz = Time.zone

        begin
          # Booker's server is always EST
          Time.zone = Booker::Client::BOOKER_SERVER_TIMEZONE
          timestamp = (Time.zone.parse(time.strftime("%Y-%m-%dT%H:%M:%S")).to_f * 1000).to_i
        ensure
          Time.zone = original_tz
        end

        "/Date(#{timestamp})/"
      end

      def timezone_from_booker_timezone(booker_timezone_name)
        normalized_booker_timezone_name = Booker::Helpers::ActiveSupport.to_active_support(booker_timezone_name)
        return normalized_booker_timezone_name if normalized_booker_timezone_name.present?

        begin
          Booker::Helpers::LoggingHelper.log_issue(
              'Unable to find time zone name using Booker::Helpers::ActiveSupport.to_active_support',
              booker_timezone_name: booker_timezone_name
          )
        rescue
        end

        timezone_from_booker_offset!(booker_timezone_name)
      end

      def timezone_from_booker_offset!(booker_timezone_name)
        booker_offset_match = booker_timezone_name.scan(/(\A)(.*)(?=\))/).first

        if booker_offset_match.present?
          booker_offset = booker_offset_match.delete_if { |match| match.blank? }.first

          if booker_offset
            booker_timezone_map_key = Booker::Helpers::ActiveSupport.booker_timezone_names.find do |key|
              key.start_with?(booker_offset)
            end

            return Booker::Helpers::ActiveSupport.to_active_support(booker_timezone_map_key) if booker_timezone_map_key
          end
        end

        raise Booker::Error
      end

      def to_wday(booker_wday); Date.parse(booker_wday).wday; end
    end
  end
end