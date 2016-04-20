module Booker
  module BusinessREST
    include CommonREST

    def get_logged_in_user
      response = get('/user', build_params)
      result = Booker::Models::User.from_hash(response['User'])
      result.LocationID = response['LocationID']
      result.BrandID = response['BrandID']
      result
    end

    def get_location(booker_location_id:)
      response = get("/location/#{booker_location_id}", build_params)
      Booker::Models::Location.from_hash(response)
    end

    def get_location_day_schedules(booker_location_id:, params: {})
      # Booker requires fromDate and toDate for JSON API, but does not use them when getDefaultDaySchedule is true
      # So datetime used for these fields does not matter
      random_datetime = Booker::Models::Model.time_to_booker_datetime(Time.now)

      additional_params = {'getDefaultDaySchedule' => true, 'fromDate' => random_datetime, 'toDate' => random_datetime}
      response = get("/location/#{booker_location_id}/schedule", build_params(additional_params, params))
      response['LocationDaySchedules'].map { |sched| Booker::Models::LocationDaySchedule.from_hash(sched) }
    end

    def find_locations(params: {})
      paginated_request(
          method: :post,
          path: '/locations',
          params: build_params({}, params, true),
          model: Booker::Models::Location
      )
    end

    def find_employees(booker_location_id:, fetch_all: true, params: {})
      paginated_request(
          method: :post,
          path: '/employees',
          params: build_params({'LocationID' => booker_location_id}, params, true),
          model: Booker::Models::Employee,
          fetch_all: fetch_all
      )
    end

    def find_treatments(booker_location_id:, fetch_all: true, params: {})
      paginated_request(
          method: :post,
          path: '/treatments',
          params: build_params({'LocationID' => booker_location_id}, params, true),
          model: Booker::Models::Treatment,
          fetch_all: fetch_all
      )
    end

    def find_customers(booker_location_id:, fetch_all: true, params: {})
      additional_params = {
          'FilterByExactLocationID' => true,
          'LocationID' => booker_location_id,
          'CustomerRecordType' => 1,
      }

      paginated_request(
          method: :post,
          path: '/customers',
          params: build_params(additional_params, params, true),
          model: Booker::Models::Customer,
          fetch_all: fetch_all
      )
    end

    def find_appointments(booker_location_id:, start_date:, end_date:, fetch_all: true, params: {})
      additional_params = {
          'LocationID' => booker_location_id,
          'FromStartDate' => start_date.to_date,
          'ToStartDate' => end_date.to_date
      }

      paginated_request(
          method: :post,
          path: '/appointments',
          params: build_params(additional_params, params, true),
          model: Booker::Models::Appointment,
          fetch_all: fetch_all
      )
    end

    def create_special(booker_location_id:, start_date:, end_date:, coupon_code:, name:, params: {})
      post('/special', build_params({
            'LocationID' => booker_location_id,
            'ApplicableStartDate' => start_date.in_time_zone,
            'ApplicableEndDate' => end_date.in_time_zone,
            'CouponCode' => coupon_code,
            'Name' => name
          }, params))
    end
  end
end
