module Booker
  module V4
    module CustomerREST
      include Booker::V4::CommonREST

      def create_appointment(booker_location_id:, available_time:, customer:, params: {})
        post '/appointment/create', build_params({
                                                     'LocationID' => booker_location_id,
                                                     'ItineraryTimeSlotList' => [
                                                         'TreatmentTimeSlots' => [available_time]
                                                     ],
                                                     'Customer' => customer
                                                 }, params), Booker::V4::Models::Appointment
      end

      def create_class_appointment(booker_location_id:, class_instance_id:, customer:, params: {})
        post '/class_appointment/create', build_params({
                                                           LocationID: booker_location_id,
                                                           ClassInstanceID: class_instance_id,
                                                           Customer: customer
                                                       }, params), Booker::V4::Models::Appointment
      end

      def run_class_availability(booker_location_id:, from_start_date_time:, to_start_date_time:, params: {})
        post '/availability/class', build_params({
                                                     FromStartDateTime: from_start_date_time,
                                                     LocationID: booker_location_id,
                                                     OnlyIfAvailable: true,
                                                     ToStartDateTime: to_start_date_time,
                                                     ExcludeClosedDates: true
                                                 }, params), Booker::V4::Models::ClassInstance
      end
    end
  end
end
