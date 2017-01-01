module Booker
  module V41
    class Booking < Client
      include Booker::V4::RequestHelper

      API_METHODS = {
        appointment: '/v4.1/booking/appointment'.freeze,
        cancel_appointment: '/v4.1/booking/appointment/cancel'.freeze,
        create_appointment: '/v4.1/booking/appointment/create'.freeze,
        appointment_hold: '/v4.1/booking/appointment/hold'.freeze,
        employees: '/v4.1/booking/employees'.freeze,
        services: '/v4.1/booking/services'.freeze,
        location: '/v4.1/booking/location'.freeze,
        locations: '/v4.1/booking/locations'.freeze
      }.freeze

      def appointment(id:)
        get "#{API_METHODS[:appointment]}/#{id}", build_params, Booker::V4::Models::Appointment
      end

      def cancel_appointment(id:, options:{})
        put API_METHODS[:cancel_appointment], build_params({ID: id}, options), Booker::V4::Models::Appointment
      end

      def create_appointment(location_id:, available_time:, customer:, options: {})
        post API_METHODS[:create_appointment], build_params({
          LocationID: location_id,
          ItineraryTimeSlotList: [
            TreatmentTimeSlots: [available_time]
          ],
          Customer: customer
        }, options), Booker::V4::Models::Appointment
      end

      def create_appointment_hold(location_id:, available_time:, customer:, options: {})
        post API_METHODS[:appointment_hold], build_params({
          LocationID: location_id,
          ItineraryTimeSlot: {
            TreatmentTimeSlots: [available_time]
          },
          Customer: customer
        }, options)
      end

      def delete_appointment_hold(location_id:, incomplete_appointment_id:)
        delete API_METHODS[:appointment_hold], nil, build_params({
          LocationID: location_id,
          IncompleteAppointmentID: incomplete_appointment_id
        })
      end

      def employees(location_id:, fetch_all: true, options: {})
        paginated_request(
          method: :post,
          path: API_METHODS[:employees],
          params: build_params({LocationID: location_id}, options, true),
          model: Booker::V4::Models::Employee,
          fetch_all: fetch_all
        )
      end

      def location(id:)
        response = get("#{API_METHODS[:location]}/#{id}", build_params)
        Booker::V4::Models::Location.from_hash(response)
      end

      def locations(options: {})
        paginated_request(
          method: :post,
          path: API_METHODS[:locations],
          params: build_params({}, options, true),
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
