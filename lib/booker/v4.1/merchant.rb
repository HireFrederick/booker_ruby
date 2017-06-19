module Booker
  module V41
    class Merchant < Booker::Client
      include Booker::V4::RequestHelper

      V41_PREFIX = '/v4.1/merchant'
      V41_LOCATION_PREFIX = "#{V41_PREFIX}/location"
      V41_APPOINTMENTS_PREFIX = "#{V41_PREFIX}/appointments"
      API_METHODS = {
        appointments: "#{V41_APPOINTMENTS_PREFIX}".freeze,
        appointments_partial: "#{V41_APPOINTMENTS_PREFIX}/partial".freeze,
        appointment_confirm: "#{V41_PREFIX}/appointment/confirm".freeze,
        customers: "#{V41_PREFIX}/customers".freeze,
        create_special: "#{V41_PREFIX}/special".freeze,
        employees: "#{V41_PREFIX}/employees".freeze,
        treatments: "#{V41_PREFIX}/treatments".freeze,
      }.freeze

      def online_booking_settings(location_id:)
        path = "#{V41_LOCATION_PREFIX}/#{location_id}/online_booking_settings"
        response = get path, build_params
        Booker::V4::Models::OnlineBookingSettings.from_hash(response['OnlineBookingSettings'])
      end

      def location_feature_settings(location_id:)
        response = get "#{V41_LOCATION_PREFIX}/#{location_id}/feature_settings", build_params
        Booker::V4::Models::FeatureSettings.from_hash response['FeatureSettings']
      end

      def location_day_schedules(location_id:, params: {})
        # Booker requires fromDate and toDate for JSON API, but does not use them when getDefaultDaySchedule is true
        # So datetime used for these fields does not matter
        random_datetime = Booker::V4::Models::Model.time_to_booker_datetime(Time.now)

        additional_params = {getDefaultDaySchedule: true, fromDate: random_datetime, toDate: random_datetime}
        response = get("#{V41_LOCATION_PREFIX}/#{location_id}/schedule", build_params(additional_params, params))
        response['LocationDaySchedules'].map { |sched| Booker::V4::Models::LocationDaySchedule.from_hash(sched) }
      end

      def update_location_notification_settings(location_id:, send_appointment_reminders:)
        params = build_params({NotificationSettings: { SendAppointmentReminders: send_appointment_reminders } })
        put "#{V41_LOCATION_PREFIX}/#{location_id}/notification_settings", params
      end

      def confirm_appointment(appointment_id:)
        put API_METHODS[:appointment_confirm], build_params(ID: appointment_id), Booker::V4::Models::Appointment
      end

      def appointments_partial(location_id:, start_date:, end_date:, fetch_all: true, params: {})
        additional_params = {
          LocationID: location_id,
          FromStartDate: start_date.to_date,
          ToStartDate: end_date.to_date
        }

        paginated_request(
          method: :post,
          path: API_METHODS[:appointments_partial],
          params: build_params(additional_params, params, true),
          model: Booker::V4::Models::Appointment,
          fetch_all: fetch_all
        )
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

      def treatments(location_id:, fetch_all: true, params: {})
        paginated_request(
          method: :post,
          path: API_METHODS[:treatments],
          params: build_params({ LocationID: location_id }, params, true),
          model: Booker::V4::Models::Treatment,
          fetch_all: fetch_all
        )
      end

      def location(id:)
        response = get("#{V41_LOCATION_PREFIX}/#{id}", build_params)
        Booker::V4::Models::Location.from_hash(response)
      end

      def appointments(location_id:, start_date:, end_date:, fetch_all: true, params: {})
        additional_params = {
          LocationID: location_id,
          FromStartDate: start_date.to_date,
          ToStartDate: end_date.to_date
        }

        paginated_request(
          method: :post,
          path: API_METHODS[:appointments],
          params: build_params(additional_params, params, true),
          model: Booker::V4::Models::Appointment,
          fetch_all: fetch_all
        )
      end

      def customers(location_id:, fetch_all: true, params: {})
        additional_params = {
          FilterByExactLocationID: true,
          LocationID: location_id,
          CustomerRecordType: 1,
        }

        paginated_request(
          method: :post,
          path: API_METHODS[:customers],
          params: build_params(additional_params, params, true),
          model: Booker::V4::Models::Customer,
          fetch_all: fetch_all
        )
      end

      def customer(id:, params: {})
        additional_params = {
          LoadUnpaidAppointments: false,
          includeFieldValues: false
        }
        response = get("#{V41_PREFIX}/customer/#{id}",
                       build_params(additional_params, params),
                       Booker::V4::Models::Customer)
      end

      def create_special(location_id:, start_date:, end_date:, coupon_code:, name:, params: {})
        post(API_METHODS[:create_special], build_params({
          LocationID: location_id,
          ApplicableStartDate: start_date.in_time_zone,
          ApplicableEndDate: end_date.in_time_zone,
          CouponCode: coupon_code,
          Name: name
        }, params))
      end
    end
  end
end
