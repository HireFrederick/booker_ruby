module Booker
  module V41
    class Booking < Booker::Client
      include Booker::V4::RequestHelper

      V41_PREFIX = '/v4.1/booking'
      V41_APPOINTMENTS_PREFIX = "#{V41_PREFIX}/appointment"
      API_METHODS = {
        appointment: "#{V41_APPOINTMENTS_PREFIX}".freeze,
        cancel_appointment: "#{V41_APPOINTMENTS_PREFIX}/cancel".freeze,
        create_appointment: "#{V41_APPOINTMENTS_PREFIX}/create".freeze,
        appointment_hold: "#{V41_APPOINTMENTS_PREFIX}/hold".freeze,
        employees: "#{V41_PREFIX}/employees".freeze,
        services: "#{V41_PREFIX}/services".freeze,
        location: "#{V41_PREFIX}/location".freeze,
        locations: "#{V41_PREFIX}/locations".freeze
      }.freeze

      def appointment(id:)
        get "#{API_METHODS[:appointment]}/#{id}", build_params, Booker::V4::Models::Appointment
      end

      def cancel_appointment(id:, params: {})
        put API_METHODS[:cancel_appointment], build_params({ID: id}, params), Booker::V4::Models::Appointment
      end

      def create_appointment(location_id:, available_time:, customer:, params: {})
        post API_METHODS[:create_appointment], build_params({
          LocationID: location_id,
          ItineraryTimeSlotList: [
            TreatmentTimeSlots: [available_time]
          ],
          Customer: customer
        }, params), Booker::V4::Models::Appointment
      end

      def create_appointment_hold(location_id:, available_time:, customer:, params: {})
        post API_METHODS[:appointment_hold], build_params({
          LocationID: location_id,
          ItineraryTimeSlot: {
            TreatmentTimeSlots: [available_time]
          },
          Customer: customer
        }, params)
      end

      def delete_appointment_hold(location_id:, incomplete_appointment_id:)
        delete API_METHODS[:appointment_hold], nil, build_params({
          LocationID: location_id,
          IncompleteAppointmentID: incomplete_appointment_id
        })
      end

      def employees(location_id:, fetch_all: true, params: {})
        paginated_request(
          method: :post,
          path: API_METHODS[:employees],
          params: build_params({LocationID: location_id}, params, true),
          model: Booker::V4::Models::Employee,
          fetch_all: fetch_all
        )
      end

      def location(id:)
        response = get("#{API_METHODS[:location]}/#{id}", build_params)
        Booker::V4::Models::Location.from_hash(response)
      end

      def locations(params: {})
        paginated_request(
          method: :post,
          path: API_METHODS[:locations],
          params: build_params({}, params, true),
          model: Booker::V4::Models::Location
        )
      end

      def services(location_id:, fetch_all: true, params: {})
        paginated_request(
          method: :post,
          path: API_METHODS[:services],
          params: build_params({LocationID: location_id}, params, true),
          model: Booker::V4::Models::Treatment,
          fetch_all: fetch_all
        )
      end
    end
  end
end
