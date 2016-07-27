module Booker
  module CommonREST
    DEFAULT_PAGINATION_PARAMS = {
        'UsePaging' => true,
        'PageSize' => Integer(ENV['BOOKER_DEFAULT_PAGE_SIZE'] || 10),
        'PageNumber' => 1
    }

    def get_online_booking_settings(booker_location_id:)
      response = get("/location/#{booker_location_id}/online_booking_settings", build_params)
      Booker::Models::OnlineBookingSettings.from_hash(response['OnlineBookingSettings'])
    end

    def confirm_appointment(appointment_id:)
      put '/appointment/confirm', build_params('ID' => appointment_id), Booker::Models::Appointment
    end

    def get_location(booker_location_id:)
      response = get("/location/#{booker_location_id}", build_params)
      Booker::Models::Location.from_hash(response)
    end

    private

      def build_params(default_params={}, overrides={}, paginated=false)
        merged = {"access_token" => access_token}.merge(default_params.merge(overrides))

        merged.each do |k, v|
          if v.is_a?(Time) || v.is_a?(DateTime)
            merged[k] = Booker::Models::Model.time_to_booker_datetime(v)
          elsif v.is_a?(Date)
            merged[k] = Booker::Models::Model.time_to_booker_datetime(v.in_time_zone)
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
