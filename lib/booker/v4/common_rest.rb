module Booker
  module V4
    module CommonREST
      include Booker::V4::RequestHelper

      def get_online_booking_settings(booker_location_id:)
        response = get("/location/#{booker_location_id}/online_booking_settings", build_params)
        Booker::V4::Models::OnlineBookingSettings.from_hash(response['OnlineBookingSettings'])
      end

      def confirm_appointment(appointment_id:)
        put '/appointment/confirm', build_params(:ID => appointment_id), Booker::V4::Models::Appointment
      end

      def get_location(booker_location_id:)
        response = get("/location/#{booker_location_id}", build_params)
        Booker::V4::Models::Location.from_hash(response)
      end
    end
  end
end
