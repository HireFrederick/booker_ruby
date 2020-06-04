module Booker
  module V41
    class Customer < Booker::Client
      include ::Booker::RequestHelper

      V41_PREFIX = '/v4.1/customer'
      V41_APPOINTMENTS_PREFIX = "#{V41_PREFIX}/appointment"
      API_METHODS = {
        appointment: "#{V41_APPOINTMENTS_PREFIX}".freeze,
        cancel_appointment: "#{V41_APPOINTMENTS_PREFIX}/cancel".freeze,
        create_appointment: "#{V41_APPOINTMENTS_PREFIX}/create".freeze,
        create_class_appointment: "#{V41_PREFIX}/class_appointment/create".freeze,
        employees: "#{V41_PREFIX}/employees".freeze,
        treatment: "#{V41_PREFIX}/treatment".freeze,
        treatments: "#{V41_PREFIX}/treatments".freeze,
        treatments_verified_bookable_online: "#{V41_PREFIX}/treatments/online".freeze,
        location: "#{V41_PREFIX}/location".freeze,
        locations: "#{V41_PREFIX}/locations".freeze,
        class_availability: "#{V41_PREFIX}/availability/class".freeze,
        specials: "#{V41_PREFIX}/specials".freeze
      }.freeze

      def appointment(id:)
        get "#{API_METHODS[:appointment]}/#{id}", build_params, Booker::V4::Models::Appointment
      end

      def cancel_appointment(id:, params: {})
        put API_METHODS[:cancel_appointment], build_params({ID: id}, params), Booker::V4::Models::Appointment
      end

      def create_class_appointment(location_id:, class_instance_id:, customer:, params: {})
        post API_METHODS[:create_class_appointment], build_params({
                                                         LocationID: location_id,
                                                         ClassInstanceID: class_instance_id,
                                                         Customer: customer
                                                       }, params), Booker::V4::Models::Appointment
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

      def employees(location_id:, fetch_all: true, params: {})
        paginated_request(
          method: :post,
          path: API_METHODS[:employees],
          params: build_params({LocationID: location_id}, params, true),
          model: Booker::V4::Models::Employee,
          fetch_all: fetch_all
        )
      end

      def treatment(id:, includeEmployeeTreatment: false)
        get "#{API_METHODS[:treatment]}/#{id}", build_params({
                                                               includeEmployeeTreatment: includeEmployeeTreatment
                                                             }), Booker::V4::Models::TreatmentVerifiedBookableOnline
      end

      def treatments(location_id:, fetch_all: true, params: {})
        paginated_request(
          method: :post,
          path: API_METHODS[:treatments],
          params: build_params({LocationID: location_id}, params, true),
          model: Booker::V4::Models::Treatment,
          fetch_all: fetch_all
        )
      end

      def treatments_verified_bookable_online(location_id:, fetch_all: true, params: {})
        paginated_request(
          method: :post,
          path: API_METHODS[:treatments_verified_bookable_online],
          params: build_params({LocationID: location_id}, params, true),
          model: Booker::V4::Models::TreatmentVerifiedBookableOnline,
          fetch_all: fetch_all
        )
      end

      def specials(location_id:, fetch_all: true, params: {})
        paginated_request(
          method: :post,
          path: API_METHODS[:specials],
          params: build_params({ LocationID: location_id }, params, true),
          model: Booker::V4::Models::Special,
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

      def class_availability(location_id:, from_start_date_time:, to_start_date_time:, params: {})
        post API_METHODS[:class_availability], build_params({
          FromStartDateTime: from_start_date_time,
          LocationID: location_id,
          OnlyIfAvailable: true,
          ToStartDateTime: to_start_date_time,
          ExcludeClosedDates: true
        }, params), Booker::V4::Models::ClassInstance
      end
    end
  end
end
