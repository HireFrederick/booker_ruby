module Booker
  module V41
    class Merchant < Client
      include Booker::V4::RequestHelper

      API_METHODS = {
        appointments: '/v4.1/merchant/appointments'.freeze,
        customers: '/v4.1/merchant/customers'.freeze,
        create_special: '/v4.1/merchant/special'.freeze
      }.freeze

      def appointments(location_id:, start_date:, end_date:, fetch_all: true, options: {})
        additional_params = {
          LocationID: location_id,
          FromStartDate: start_date.to_date,
          ToStartDate: end_date.to_date
        }

        paginated_request(
          method: :post,
          path: API_METHODS[:appointments],
          params: build_params(additional_params, options, true),
          model: Booker::V4::Models::Appointment,
          fetch_all: fetch_all
        )
      end

      def customers(location_id:, fetch_all: true, options: {})
        additional_params = {
          FilterByExactLocationID: true,
          LocationID: location_id,
          CustomerRecordType: 1,
        }

        paginated_request(
          method: :post,
          path: API_METHODS[:customers],
          params: build_params(additional_params, options, true),
          model: Booker::V4::Models::Customer,
          fetch_all: fetch_all
        )
      end

      def create_special(location_id:, start_date:, end_date:, coupon_code:, name:, options: {})
        post(API_METHODS[:create_special], build_params({
          LocationID: location_id,
          ApplicableStartDate: start_date.in_time_zone,
          ApplicableEndDate: end_date.in_time_zone,
          CouponCode: coupon_code,
          Name: name
        }, options))
      end
    end
  end
end
