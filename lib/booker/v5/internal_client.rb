module Booker
  module V5
    class InternalClient < Booker::Client
      include ::Booker::RequestHelper

      V5_PREFIX = '/v5'
      V5_INTERNAL_LOCATIONS_PREFIX = "#{V5_PREFIX}/internal/locations"

      def purchased_series(location_id, filters = {})
        get location_uri(location_id, 'purchased-series'), build_params.merge('filter' => filters),
            Booker::V5::Models::PurchasedSeries
      end

      private
        def location_uri(location_id, method_name)
          "#{V5_INTERNAL_LOCATIONS_PREFIX}/#{location_id}/#{method_name}"
        end
    end
  end
end
