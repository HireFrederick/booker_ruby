module Booker
  module V41
    class Availability < Client
      include Booker::V4::RequestHelper

      API_METHODS = {
        class_availability: '/v4.1/availability/availability/class'.freeze
      }.freeze

      def class_availability(location_id:, from_start_date_time:, to_start_date_time:, options: {})
        post API_METHODS[:class_availability], build_params({
          FromStartDateTime: from_start_date_time,
          LocationID: location_id,
          OnlyIfAvailable: true,
          ToStartDateTime: to_start_date_time,
          ExcludeClosedDates: true
        }, options), Booker::V4::Models::ClassInstance
      end
    end
  end
end
