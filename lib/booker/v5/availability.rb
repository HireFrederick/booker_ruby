module Booker
  module V5
    class Availability < Booker::Client
      API_METHODS = {
        availability: '/v5/availability/availability'.freeze,
        two_day_availability: '/v5/availability/2day'.freeze,
        thirty_day_availability: '/v5/availability/30day'.freeze
      }.freeze

      def search(location_ids:, from_date_time:, to_date_time:, include_employees: true)
        get API_METHODS[:availability], {
          locationIds: location_ids,
          fromDateTime: from_date_time,
          toDateTime: to_date_time,
          includeEmployees: include_employees
        }, Booker::V5::Models::AvailabilityResult
      end

      def two_day(location_id:, from_date_time:, include_employees: true)
        get API_METHODS[:two_day_availability], {
          locationId: location_id,
          fromDateTime: from_date_time,
          includeEmployees: include_employees
        }, Booker::V5::Models::AvailabilityResult
      end

      def thirty_day(location_id:, from_date_time:, include_employees: true)
        get API_METHODS[:thirty_day_availability], {
          locationId: location_id,
          fromDateTime: from_date_time,
          includeEmployees: include_employees
        }, Booker::V5::Models::AvailabilityResult
      end
    end
  end
end
