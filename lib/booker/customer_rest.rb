module Booker
  module CustomerREST
    include CommonREST

    def create_appointment(booker_location_id:, available_time:, customer:, options: {})
      post '/appointment/create', build_params({
            'LocationID' => booker_location_id,
            'ItineraryTimeSlotList' => [
              'TreatmentTimeSlots' => [available_time]
            ],
            'Customer' => customer
          }, options), Booker::Models::Appointment
    end

    def create_class_appointment(booker_location_id:, class_instance_id:, customer:, options: {})
      post '/class_appointment/create', build_params({
            'LocationID' => booker_location_id,
            'ClassInstanceID' => class_instance_id,
            'Customer' => customer
          }, options), Booker::Models::Appointment
    end

    def run_multi_spa_multi_sub_category_availability(booker_location_ids:, treatment_sub_category_ids:, start_date_time:, end_date_time:, options: {})
      post '/availability/multispamultisubcategory', build_params({
            'LocationIDs' => booker_location_ids,
            'TreatmentSubCategoryIDs' => treatment_sub_category_ids,
            'StartDateTime' => start_date_time,
            'EndDateTime' => end_date_time,
            'MaxTimesPerTreatment' => 1000
          }, options), Booker::Models::SpaEmployeeAvailabilitySearchItem
    end

    def run_class_availability(booker_location_id:, from_start_date_time:, to_start_date_time:, options: {})
      post '/availability/class', build_params({
          'FromStartDateTime' => from_start_date_time,
          'LocationID' => booker_location_id,
          'OnlyIfAvailable' => true,
          'ToStartDateTime' => to_start_date_time,
          'ExcludeClosedDates' => true
        }, options), Booker::Models::ClassInstance
    end
  end
end
