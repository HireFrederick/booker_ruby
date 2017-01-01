module Booker
  module V4
    module RequestHelper
      DEFAULT_PAGINATION_PARAMS = {
        UsePaging: true,
        PageSize: Integer(ENV['BOOKER_DEFAULT_PAGE_SIZE'] || 10),
        PageNumber: 1
      }

      private

      def build_params(default_params={}, overrides={}, paginated=false)
        default_params.symbolize_keys!
        overrides.symbolize_keys!
        merged = {access_token: access_token}.merge(default_params.merge(overrides))

        merged.each do |k, v|
          if v.is_a?(Time) || v.is_a?(DateTime)
            merged[k] = Booker::V4::Models::Model.time_to_booker_datetime(v)
          elsif v.is_a?(Date)
            merged[k] = Booker::V4::Models::Model.time_to_booker_datetime(v.in_time_zone)
          end
        end

        if paginated
          DEFAULT_PAGINATION_PARAMS.merge(merged)
        else
          merged
        end
      end
    end
  end
end
