module Booker
  module V5
    class Availability < Client
      API_METHODS = {
        search: '/v5/availability/availability'.freeze
      }.freeze

      def search(location_ids:, from_date_time:, to_date_time:, include_employees: true)
        get API_METHODS[:search], {
          locationIds: location_ids,
          fromDateTime: from_date_time,
          toDateTime: to_date_time,
          includeEmployees: include_employees
        }, Booker::V5::Models::AvailabilityResult
      end
    end
  end
end
