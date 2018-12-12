require 'spec_helper'

describe Booker::V4::BusinessREST do
  let(:client) do
    Booker::V4::BusinessClient.new(
      client_id: 'foo_client_id',
      client_secret: 'foo_client_secret',
    )
  end
  let(:booker_location_id) { 10257 }

  describe '#get_logged_in_user' do
    let(:result) { client.get_logged_in_user }
    let(:expected_params) {{
      access_token: 'access_token'
    }}
    let(:response) {{
      'User' => {
        'ID' => 98864422
      },
      'LocationID' => 5678,
      'BrandID' => 9101112
    }}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:get).with('/user', expected_params).and_return(response)
    end

    it 'delegates to get and returns' do
      expect(result).to be_a Booker::V4::Models::User
      expect(result.ID).to be 98864422
      expect(result.LocationID).to be 5678
      expect(result.BrandID).to be 9101112
    end
  end

  describe '#get_location_day_schedules' do
    let(:result) { client.get_location_day_schedules(booker_location_id: booker_location_id) }
    let(:access_token) { 'access_token' }
    let(:now) { Time.zone.parse('2014-01-01') }
    let(:random_datetime) { Booker::V4::Models::Model.time_to_booker_datetime(Time.zone.now) }
    let(:additional_params) do
      {
        getDefaultDaySchedule: true,
        fromDate: random_datetime,
        toDate: random_datetime
      }
    end
    let(:expected_params) do
      {
        access_token: access_token,
      }.merge(additional_params)
    end
    let(:start_time) { Time.parse('2014-01-09') }
    let(:end_time) { Time.parse('2014-01-10') }
    let(:location_day_sched_resp) { {'Weekday' => 'Sunday', 'StartTime' => start_time} }
    let(:location_day_sched_resp2) { {'Weekday' => 'Tuesday', 'EndTime' => end_time} }
    let(:response) { {'LocationDaySchedules' => [location_day_sched_resp, location_day_sched_resp2]} }
    let(:first_result) { result.first }
    let(:second_result) { result[1] }

    before do
      allow(Time).to receive(:now).and_return(now)
      expect(client).to receive(:access_token).and_return access_token
      expect(client).to receive(:build_params).with(additional_params, {}).and_call_original
      expect(Booker::V4::Models::LocationDaySchedule).to receive(:from_hash).with(location_day_sched_resp).and_call_original
      expect(Booker::V4::Models::LocationDaySchedule).to receive(:from_hash).with(location_day_sched_resp2).and_call_original
      expect(client).to receive(:get).with("/location/#{booker_location_id}/schedule", expected_params).and_return(response)
    end

    it 'delegates to get and returns' do
      expect(result.length).to eq 2

      expect(first_result).to be_a Booker::V4::Models::LocationDaySchedule
      expect(first_result.Weekday).to eq 0
      expect(first_result.StartTime).to eq start_time.strftime('%T')
      expect(first_result.EndTime).to eq nil

      expect(second_result).to be_a Booker::V4::Models::LocationDaySchedule
      expect(second_result.Weekday).to eq 2
      expect(second_result.StartTime).to eq nil
      expect(second_result.EndTime).to eq end_time.strftime('%T')
    end
  end

  describe '#find_locations' do
    let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
      access_token: 'access_token'
    })}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:paginated_request).with(
          method: :post,
          path: '/locations',
          params: expected_params,
          model: Booker::V4::Models::Location
      ).and_return([])
    end

    it 'delegates to paginated_request' do
      expect(client.find_locations).to eq []
    end

    context 'other options' do
      let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
        access_token: 'access_token',
        another_option: 'foo'
      })}

      it 'adds other params passed in to the params' do
        expect(client.find_locations(params: {another_option: 'foo'})).to eq []
      end
    end
  end

  describe '#find_employees' do
    let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
      access_token: 'access_token',
      LocationID: booker_location_id
    })}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:paginated_request).with(
          method: :post,
          path: '/employees',
          params: expected_params,
          model: Booker::V4::Models::Employee,
          fetch_all: true
      ).and_return([])
    end

    it 'delegates to get_booker_resources' do
      expect(client.find_employees(booker_location_id: booker_location_id)).to eq []
    end

    context 'other params' do
      let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
        access_token: 'access_token',
        LocationID: booker_location_id,
        another_option: 'foo'
      })}

      it 'adds other params passed in to the params' do
        expect(client.find_employees(booker_location_id: booker_location_id, params: {another_option: 'foo'})).to eq []
      end
    end
  end

  describe '#find_orders' do
    let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
      access_token: 'access_token',
      LocationID: booker_location_id
    })}
    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:paginated_request).with(
          method: :post,
          path: '/orders',
          params: expected_params,
          model: Booker::V4::Models::Order,
          fetch_all: true
      ).and_return([])
    end

    it 'delegates to get_booker_resources' do
      expect(client.find_orders(booker_location_id: booker_location_id)).to eq []
    end

    context 'other params' do
      let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
        access_token: 'access_token',
        LocationID: booker_location_id,
        another_option: 'foo'
      })}

      it 'adds other params passed in to the params' do
        expect(client.find_orders(booker_location_id: booker_location_id, params: {another_option: 'foo'})).to eq []
      end
    end
  end

  describe '#find_orders_partial' do
    let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
                                                                                access_token: 'access_token',
                                                                                LocationID: booker_location_id
                                                                            })}
    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:paginated_request).with(
          method: :post,
          path: '/orders/partial',
          params: expected_params,
          model: Booker::V4::Models::Order,
          fetch_all: true
      ).and_return([])
    end

    it 'delegates to get_booker_resources' do
      expect(client.find_orders_partial(booker_location_id: booker_location_id)).to eq []
    end

    context 'other params' do
      let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
                                                                                  access_token: 'access_token',
                                                                                  LocationID: booker_location_id,
                                                                                  another_option: 'foo'
                                                                              })}

      it 'adds other params passed in to the params' do
        expect(client.find_orders_partial(booker_location_id: booker_location_id, params: {another_option: 'foo'})).to eq []
      end
    end
  end

  describe '#find_treatments' do
    let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
      access_token: 'access_token',
      LocationID: booker_location_id
    })}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:paginated_request).with(
          method: :post,
          path: '/treatments',
          params: expected_params,
          model: Booker::V4::Models::Treatment,
          fetch_all: true
      ).and_return([])
    end

    it 'delegates to get_booker_resources' do
      expect(client.find_treatments(booker_location_id: booker_location_id)).to eq []
    end

    context 'other params' do
      let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
        access_token: 'access_token',
        LocationID: booker_location_id,
        another_option: 'foo'
      })}

      it 'adds other params passed in to the params' do
        expect(client.find_treatments(booker_location_id: booker_location_id, params: {another_option: 'foo'})).to eq []
      end
    end
  end

  describe '#find_customers' do
    let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
                                                                                :'access_token' => 'access_token',
                                                                                :'FilterByExactLocationID' => true,
                                                                                :'LocationID' => booker_location_id,
                                                                                :'CustomerRecordType' => 1,
                                                                            })}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:paginated_request).with(
          method: :post,
          path: '/customers',
          params: expected_params,
          model: Booker::V4::Models::Customer,
          fetch_all: true
      ).and_return([])
    end

    it 'delegates to get_booker_resources' do
      expect(client.find_customers(booker_location_id: booker_location_id)).to eq []
    end

    context 'other params' do
      let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
                                                                                  :'access_token' => 'access_token',
                                                                                  :'FilterByExactLocationID' => true,
                                                                                  :'CustomerRecordType' => 1,
                                                                                  :'LocationID' => booker_location_id,
                                                                                  :'another_option' => 'foo'
                                                                              })}

      it 'adds other params passed in to the params' do
        expect(client.find_customers(booker_location_id: booker_location_id, params: {'another_option' => 'foo'})).to eq []
      end
    end
  end

  describe '#create_special' do
    let(:start_date) { Time.zone.at(1438660800) }
    let(:end_date) { Time.zone.at(1438747199) }
    let(:coupon_code) { 'fred123456' }
    let(:name) { 'Frederick 20% Off' }
    let(:params) {{
        'Type' => 2,
        'AdjustmentType' => 1,
        'DiscountType' => 1,
        'DiscountAmount' => 20,
        'MaxRedemptions' => 1,
        'Description' => 'foo',
        'BookingStartDate' => start_date,
        'BookingEndDate' => end_date,
        'IsExclusiveWithAll' => true
    }}
    let(:result) do
      client.create_special(
          booker_location_id: booker_location_id,
          start_date: start_date,
          end_date: end_date,
          coupon_code: coupon_code,
          name: name,
          params: params
      )
    end
    let(:expected_params) {{
        :'access_token' => 'access_token',
        :'LocationID' =>booker_location_id,
        :'ApplicableStartDate' => '/Date(1438675200000)/',
        :'ApplicableEndDate' => '/Date(1438761599000)/',
        :'CouponCode' => 'fred123456',
        :'Name' => 'Frederick 20% Off',
        :'Type' => 2,
        :'AdjustmentType' => 1,
        :'DiscountType' => 1,
        :'DiscountAmount' => 20,
        :'MaxRedemptions' => 1,
        :'Description' => 'foo',
        :'BookingStartDate' => Booker::V4::Models::Model.time_to_booker_datetime(start_date),
        :'BookingEndDate' => Booker::V4::Models::Model.time_to_booker_datetime(end_date),
        :'IsExclusiveWithAll' => true
    }}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:post).with('/special', expected_params).and_return 'response'
    end

    it 'delegates to post' do
      expect(result).to eq 'response'
    end
  end

  describe '#find_appointments_partial' do
    let(:from_start_date) { Time.zone.at(1375039103) }
    let(:to_start_date) { Time.zone.at(1469743856) }
    let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
      access_token: 'access_token',
      LocationID: booker_location_id,
      FromStartDate: '/Date(1374984000000)/',
      ToStartDate: '/Date(1469678400000)/'
    })}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:paginated_request).with(
        method: :post,
        path: '/appointments/partial',
        params: expected_params,
        model: Booker::V4::Models::Appointment,
        fetch_all: true
      ).and_return([])
    end

    it 'delegates to get_booker_resources' do
      expect(client.find_appointments_partial(booker_location_id: booker_location_id, start_date: from_start_date, end_date: to_start_date)).to eq []
    end

    context 'other params' do
      let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
        access_token: 'access_token',
        LocationID: booker_location_id,
        FromStartDate: '/Date(1374984000000)/',
        ToStartDate: '/Date(1469678400000)/',
        another_option: 'foo'
      })}

      it 'adds other params passed in to the params' do
        expect(client.find_appointments_partial(booker_location_id: booker_location_id, start_date: from_start_date, end_date: to_start_date, params: {another_option: 'foo'})).to eq []
      end
    end
  end

  describe '#get_location_notification_settings' do
    let(:result) { client.get_location_notification_settings(booker_location_id: 10257) }
    let(:expected_params) {{
      access_token: 'access_token'
    }}
    let(:response) {{
      'NotificationSettings' => {
        'SendNoticeHoursBeforeAppointment' => 48
      }
    }}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:get).with('/location/10257/notification_settings', expected_params).and_return(response)
    end

    it 'delegates to get and returns' do
      expect(result).to be_a Booker::V4::Models::NotificationSettings
      expect(result.SendNoticeHoursBeforeAppointment).to be 48
    end
  end

  describe '#update_location_notification_settings' do
    let(:send_appointment_reminders) { 'foo' }
    let(:result) { client.update_location_notification_settings(booker_location_id: 10257, send_appointment_reminders: send_appointment_reminders) }
    let(:expected_params) {{
      access_token: 'access_token',
      NotificationSettings: {SendAppointmentReminders: send_appointment_reminders}
    }}
    let(:response) {{
      'IsSuccess' => true
    }}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:put).with('/location/10257/notification_settings', expected_params).and_return(response)
    end

    it 'delegates to get and returns' do
      expect(result).to be response
    end
  end

  describe '#get_location_feature_settings' do
    let(:result) { client.get_location_feature_settings(booker_location_id: 10257) }
    let(:expected_params) {{
      access_token: 'access_token'
    }}
    let(:response) {{
      'FeatureSettings' => {
        'UseFrederick' => true
      }
    }}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:get).with('/location/10257/feature_settings', expected_params).and_return(response)
    end

    it 'delegates to get and returns' do
      expect(result).to be_a Booker::V4::Models::FeatureSettings
      expect(result.UseFrederick).to be true
    end
  end
end
