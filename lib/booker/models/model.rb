module Booker
  module Models
    class Model
      def initialize(options = {})
        options.each { |key, value| send(:"#{key}=", value) }
      end

      def to_hash
        hash = {}
        self.instance_variables.each do |var|
          value = self.instance_variable_get var
          if value.is_a? Array
            new_value = hash_list(value)
          elsif value.is_a? Booker::Models::Model
            new_value = value.to_hash
          elsif value.is_a? Time
            new_value = self.class.time_to_booker_datetime(value)
          elsif value.is_a? Date
            time = value.in_time_zone
            new_value = self.class.time_to_booker_datetime(time)
          else
            new_value = value
          end
          hash[var[1..-1]] = new_value
        end
        hash
      end

      def to_json; Oj.dump(to_hash, mode: :compat); end

      def self.from_hash(hash)
        model = self.new
        hash.each do |key, value|
          if model.respond_to?(:"#{key}")
            constantized = self.constantize(key)
            if constantized
              if value.is_a?(Array) && value.first.is_a?(Hash)
                model.send(:"#{key}=", constantized.from_list(value))
                next
              elsif value.is_a? Hash
                model.send(:"#{key}=", constantized.from_hash(value))
                next
              end
            end

            if value.is_a?(String) && value.start_with?('/Date(')
              model.send(:"#{key}=", time_from_booker_datetime(value))
            elsif !value.nil?
              model.send(:"#{key}=", value)
            end
          end
        end
        model
      end

      def self.from_list(array); array.map { |item| self.from_hash(item) }; end

      def self.constantize(key)
        begin
          Booker::Models.const_get("Booker::Models::#{key.singularize}")
        rescue NameError
          nil
        end
      end

      # Booker's API hands you back all time as if the business is in server time.
      # First load the time in server time, then return the same hours and minutes in current time zone.
      # Booker will hopefully fix this in a future API version. Sorry.
      def self.time_from_booker_datetime(booker_datetime)
        timestamp = booker_datetime[/\/Date\((.\d+)[\-\+]/, 1].to_i / 1000.to_f

        original_tz = Time.zone
        begin
          # Booker's server is always EST
          Time.zone = Booker::Client::TimeZone

          booker_time = Time.zone.at(timestamp)
        ensure
          Time.zone = original_tz
        end

        # Convert it back to location time without changing hours and minutes
        Time.zone.parse(booker_time.strftime('%Y-%m-%d %H:%M:%S'))
      end

      # Booker's API requires times to be sent in as if the business is in Eastern Time!
      def self.time_to_booker_datetime(time)
        original_tz = Time.zone

        begin
          # Booker's server is always EST
          Time.zone = Booker::Client::TimeZone
          timestamp = (Time.zone.parse(time.strftime("%Y-%m-%dT%H:%M:%S")).to_f * 1000).to_i
        ensure
          Time.zone = original_tz
        end

        "/Date(#{timestamp})/"
      end

      def self.timezone_from_booker_timezone(booker_timezone_name)
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

      def self.timezone_from_booker_offset!(booker_timezone_name)
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

      def self.to_wday(booker_wday); Date.parse(booker_wday).wday; end

      private
        def hash_list(array)
          array.map do |item|
            if item.is_a? Array
              hash_list(item)
            elsif item.is_a? Booker::Models::Model
              item.to_hash
            else
              item
            end
          end
        end
    end
  end
end
