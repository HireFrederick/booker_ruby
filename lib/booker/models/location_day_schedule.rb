module Booker
  module Models
    class LocationDaySchedule < Model
      attr_accessor 'Weekday',
                    'StartTime',
                    'EndTime'

      def self.from_hash(hash)
        model = super
        model.Weekday = to_wday(model.Weekday)
        strftime_format = '%T'
        model.StartTime = model.StartTime.try(:strftime, strftime_format)
        model.EndTime = model.EndTime.try(:strftime, strftime_format)
        model
      end
    end
  end
end
