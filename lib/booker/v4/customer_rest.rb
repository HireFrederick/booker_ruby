module Booker
  module V4
    module CustomerREST
      include Booker::V4::CommonREST

      def create_class_appointment(booker_location_id:, class_instance_id:, customer:, options: {})
        post '/class_appointment/create', build_params({
          LocationID: booker_location_id,
          ClassInstanceID: class_instance_id,
          Customer: customer
        }, options), Booker::V4::Models::Appointment
      end
    end
  end
end
