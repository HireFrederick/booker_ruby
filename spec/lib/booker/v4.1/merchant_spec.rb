require 'spec_helper'

describe Booker::V41::Merchant do
  let(:client) do
    Booker::V41::Merchant.new(
      client_id: 'foo_client_id',
      client_secret: 'foo_client_secret',
      auth_with_client_credentials: true
    )
  end
  let(:booker_location_id) { 10257 }
  let(:response) { 'resp' }
  let(:v41_location_prefix) { '/v4.1/merchant/location' }
  let(:v41_prefix) { '/v4.1/merchant' }
  let(:v41_appointments_prefix) { '/v4.1/merchant/appointments' }
  let(:access_token) { 'access_token' }
  let(:base_params) { { access_token: access_token } }
  let(:nested_resp) { { 'foo' => 'bar' } }
  let(:response_key) { 'response_key' }
  let(:response) { { response_key => nested_resp } }
  let(:base_pagination_params) do
    {
      UsePaging: true,
      PageSize: 10,
      PageNumber: 1,
      access_token: access_token
    }
  end

  before { allow(client).to receive(:access_token).and_return access_token }

  it { is_expected.to be_a Booker::Client }

  describe 'constants' do
    let(:api_methods) do
      {
        appointments: "#{v41_appointments_prefix}",
        appointments_partial: "#{v41_appointments_prefix}/partial",
        appointment_confirm: "#{v41_prefix}/appointment/confirm",
        customers: "#{v41_prefix}/customers",
        create_special: "#{v41_prefix}/special",
        employees: "#{v41_prefix}/employees",
        treatments: "#{v41_prefix}/treatments"
      }
    end

    it 'get set to the correct values' do
      expect(described_class::V41_PREFIX).to eq(v41_prefix)
      expect(described_class::V41_LOCATION_PREFIX).to eq(v41_location_prefix)
      expect(described_class::V41_APPOINTMENTS_PREFIX).to eq(v41_appointments_prefix)
      expect(described_class::API_METHODS).to eq(api_methods)
    end
  end

  describe '#online_booking_settings' do
    let(:path) { "#{v41_location_prefix}/#{booker_location_id}/online_booking_settings" }
    let(:response_key) { 'OnlineBookingSettings' }

    after do
      expect(client.online_booking_settings(location_id: booker_location_id)).to be_a Booker::V4::Models::OnlineBookingSettings
    end

    it 'calls get and returns the modeled response' do
      expect(client).to receive(:build_params).with(no_args).and_call_original
      expect(client).to receive(:get).with(path, base_params).and_return(response)
      expect(Booker::V4::Models::OnlineBookingSettings).to receive(:from_hash).with(nested_resp).and_call_original
    end
  end

  describe '#location_feature_settings' do
    let(:path) { "#{v41_location_prefix}/#{booker_location_id}/feature_settings" }
    let(:response_key) { 'FeatureSettings' }

    after do
      expect(client.location_feature_settings(location_id: booker_location_id)).to be_a Booker::V4::Models::FeatureSettings
    end

    it 'calls get and returns the modeled response' do
      expect(client).to receive(:build_params).with(no_args).and_call_original
      expect(client).to receive(:get).with(path, base_params).and_return(response)
      expect(Booker::V4::Models::FeatureSettings).to receive(:from_hash).with(nested_resp).and_call_original
    end
  end

  describe '#location_day_schedules' do
    let(:path) { "#{v41_location_prefix}/#{booker_location_id}/schedule" }
    let(:response_key) { 'LocationDaySchedules' }
    let(:sched) { { 'Weekday' => 'Monday' } }
    let(:sched2) { { 'Weekday' => 'Tuesday' } }
    let(:nested_resp) { [sched, sched2] }
    let(:random_datetime) { kind_of(String) }
    let!(:now) { Time.parse('2015-01-09') }
    let(:additional_params) { { getDefaultDaySchedule: true, fromDate: random_datetime, toDate: random_datetime } }
    let(:params) { {} }
    let(:location_day_schedules_expectations) do
      expect(Booker::V4::Models::Model).to receive(:time_to_booker_datetime).with(now).and_call_original
      expect(client).to receive(:build_params).with(additional_params, params).and_call_original
      expect(client).to receive(:get).with(path, base_params.merge(additional_params).merge(params)).and_return(response)
      expect(Booker::V4::Models::LocationDaySchedule).to receive(:from_hash).with(sched).and_call_original
      expect(Booker::V4::Models::LocationDaySchedule).to receive(:from_hash).with(sched2).and_call_original
    end
    let(:location_day_schedules_options) { { location_id: booker_location_id } }

    before { allow(Time).to receive(:now).with(no_args).and_return(now) }

    after do
      location_day_schedules = client.location_day_schedules(location_day_schedules_options)
      expect(location_day_schedules.length).to be 2
      expect(location_day_schedules.map(&:class).uniq).to eq [Booker::V4::Models::LocationDaySchedule]
    end

    it('calls get and returns the modeled response') { location_day_schedules_expectations }

    context 'params passed in' do
      let(:params) { { alternative: 'facts' } }
      let(:location_day_schedules_options) { { location_id: booker_location_id, params: params } }

      it('calls get and returns the modeled response') { location_day_schedules_expectations }
    end
  end

  describe '#update_location_notification_settings' do
    let(:path) { "#{v41_location_prefix}/#{booker_location_id}/notification_settings" }
    let(:send_appointment_reminders) { 'send_appointment_reminders' }
    let(:params) { { NotificationSettings: { SendAppointmentReminders: send_appointment_reminders } } }

    after do
      expect(client.update_location_notification_settings(location_id: booker_location_id, send_appointment_reminders: send_appointment_reminders)).to eq response
    end

    it 'calls get and returns the modeled response' do
      expect(client).to receive(:build_params).with(params).and_call_original
      expect(client).to receive(:put).with(path, base_params.merge(params)).and_return(response)
    end
  end

  describe '#confirm_appointment' do
    let(:path) { "#{v41_prefix}/appointment/confirm" }
    let(:appointment_id) { 'appointment_id' }
    let(:params) { { ID: appointment_id } }

    after do
      expect(client.confirm_appointment(appointment_id: appointment_id)).to eq response
    end

    it 'calls get and returns the modeled response' do
      expect(client).to receive(:build_params).with(params).and_call_original
      expect(client).to receive(:put).with(path, base_params.merge(params), Booker::V4::Models::Appointment).and_return(response)
    end
  end

  describe '#appointments_partial' do
    let(:start_date) { Time.zone.at(1375039103) }
    let(:end_date) { Time.zone.at(1469743856) }
    let(:path) { "#{v41_appointments_prefix}/partial" }
    let(:additional_params) do
      {
        LocationID: booker_location_id,
        FromStartDate: start_date.to_date,
        ToStartDate: end_date.to_date
      }
    end
    let(:request_params) do
      {
        LocationID: booker_location_id,
        FromStartDate: Booker::V4::Models::Model.time_to_booker_datetime(start_date.to_date),
        ToStartDate: Booker::V4::Models::Model.time_to_booker_datetime(end_date.to_date)
      }
    end
    let(:params) { {} }
    let(:fetch_all) { true }
    let(:appointments_partial_expectations) do
      expect(client).to receive(:build_params).with(additional_params, params, true).and_call_original
      expect(client).to receive(:paginated_request).with(
        method: :post,
        path: path,
        params: base_pagination_params.merge(request_params).merge(params),
        model: Booker::V4::Models::Appointment,
        fetch_all: fetch_all
      ).and_return(response)
    end
    let(:appointments_partial_options) { { location_id: booker_location_id, start_date: start_date, end_date: end_date } }

    after { expect(client.appointments_partial(appointments_partial_options)).to eq response }

    it('calls get and returns the modeled response') { appointments_partial_expectations }

    context 'params passed in' do
      let(:params) { { alternative: 'facts' } }
      let(:appointments_partial_options) do
        {location_id: booker_location_id, start_date: start_date, end_date: end_date, params: params}
      end

      it('calls get and returns the modeled response') { appointments_partial_expectations }
    end

    context 'fetch_all passed in' do
      let(:fetch_all) { false }
      let(:appointments_partial_options) do
        {location_id: booker_location_id, start_date: start_date, end_date: end_date, fetch_all: fetch_all}
      end

      it('calls get and returns the modeled response') { appointments_partial_expectations }
    end
  end

  describe '#employees' do
    let(:path) { "#{v41_prefix}/employees" }
    let(:additional_params) { {LocationID: booker_location_id} }
    let(:params) { {} }
    let(:fetch_all) { true }
    let(:employees_expectations) do
      expect(client).to receive(:build_params).with(additional_params, params, true).and_call_original
      expect(client).to receive(:paginated_request).with(
        method: :post,
        path: path,
        params: base_pagination_params.merge(additional_params).merge(params),
        model: Booker::V4::Models::Employee,
        fetch_all: fetch_all
      ).and_return(response)
    end
    let(:employees_options) { { location_id: booker_location_id } }

    after { expect(client.employees(employees_options)).to eq response }

    it('calls get and returns the modeled response') { employees_expectations }

    context 'params passed in' do
      let(:params) { { alternative: 'facts' } }
      let(:employees_options) do
        {location_id: booker_location_id, params: params}
      end

      it('calls get and returns the modeled response') { employees_expectations }
    end

    context 'fetch_all passed in' do
      let(:fetch_all) { false }
      let(:employees_options) do
        {location_id: booker_location_id, fetch_all: fetch_all}
      end

      it('calls get and returns the modeled response') { employees_expectations }
    end
  end

  describe '#treatments' do
    let(:path) { "#{v41_prefix}/treatments" }
    let(:additional_params) { {LocationID: booker_location_id} }
    let(:params) { {} }
    let(:fetch_all) { true }
    let(:treatments_expectations) do
      expect(client).to receive(:build_params).with(additional_params, params, true).and_call_original
      expect(client).to receive(:paginated_request).with(
        method: :post,
        path: path,
        params: base_pagination_params.merge(additional_params).merge(params),
        model: Booker::V4::Models::Treatment,
        fetch_all: fetch_all
      ).and_return(response)
    end
    let(:treatments_options) { { location_id: booker_location_id } }

    after { expect(client.treatments(treatments_options)).to eq response }

    it('calls get and returns the modeled response') { treatments_expectations }

    context 'params passed in' do
      let(:params) { { alternative: 'facts' } }
      let(:treatments_options) do
        {location_id: booker_location_id, params: params}
      end

      it('calls get and returns the modeled response') { treatments_expectations }
    end

    context 'fetch_all passed in' do
      let(:fetch_all) { false }
      let(:treatments_options) do
        {location_id: booker_location_id, fetch_all: fetch_all}
      end

      it('calls get and returns the modeled response') { treatments_expectations }
    end
  end

  describe '#location' do
    let(:path) { "#{v41_location_prefix}/#{booker_location_id}" }
    let(:response_key) { 'FeatureSettings' }

    after do
      expect(client.location(id: booker_location_id)).to be_a Booker::V4::Models::Location
    end

    it 'calls get and returns the modeled response' do
      expect(client).to receive(:build_params).with(no_args).and_call_original
      expect(client).to receive(:get).with(path, base_params).and_return(nested_resp)
      expect(Booker::V4::Models::Location).to receive(:from_hash).with(nested_resp).and_call_original
    end
  end

  describe '#appointments' do
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
        path: '/v4.1/merchant/appointments',
        params: expected_params,
        model: Booker::V4::Models::Appointment,
        fetch_all: true
      ).and_return([])
    end

    it 'delegates to get_booker_resources' do
      expect(client.appointments(location_id: booker_location_id, start_date: from_start_date, end_date: to_start_date)).to eq []
    end

    context 'other params' do
      let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
        access_token: 'access_token',
        LocationID: booker_location_id,
        FromStartDate: '/Date(1374984000000)/',
        ToStartDate: '/Date(1469678400000)/',
        another_option: 'foo'
      })}

      it 'merges passed params into base params' do
        expect(client.appointments(location_id: booker_location_id, start_date: from_start_date, end_date: to_start_date, params: {another_option: 'foo'})).to eq []
      end
    end
  end

  describe '#customers' do
    let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
      access_token: 'access_token',
      FilterByExactLocationID: true,
      CustomerRecordType: 1,
      LocationID: booker_location_id
    })}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:paginated_request).with(
        method: :post,
        path: '/v4.1/merchant/customers',
        params: expected_params,
        model: Booker::V4::Models::Customer,
        fetch_all: true
      ).and_return([])
    end

    it 'delegates to get_booker_resources' do
      expect(client.customers(location_id: booker_location_id)).to eq []
    end

    context 'other params' do
      let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
        access_token: 'access_token',
        FilterByExactLocationID: true,
        CustomerRecordType: 1,
        LocationID: booker_location_id,
        another_option: 'foo'
      })}

      it 'merges passed params into base params' do
        expect(client.customers(location_id: booker_location_id, params: {another_option: 'foo'})).to eq []
      end
    end
  end

  describe '#customer' do
    let(:path) { "#{v41_prefix}/customer/#{customer_id}" }
    let(:customer_id) { 123 }
    let(:response_key) { 'CustomerID' }

    after do
      expect(client.customer(id: customer_id)).to be_a Booker::V4::Models::Customer
    end

    it 'calls get and returns the modeled response' do
      expect(client).to receive(:build_params).with(no_args).and_call_original
      expect(client).to receive(:get).with(path, base_params).and_return(nested_resp)
      expect(Booker::V4::Models::Customer).to receive(:from_hash).with(nested_resp).and_call_original
    end
  end

  describe '#create_special' do
    let(:start_date) { Time.zone.at(1438660800) }
    let(:end_date) { Time.zone.at(1438747199) }
    let(:coupon_code) { 'fred123456' }
    let(:name) { 'Frederick 20% Off' }
    let(:params) {{
      Type: 2,
      AdjustmentType: 1,
      DiscountType: 1,
      DiscountAmount: 20,
      MaxRedemptions: 1,
      Description: 'foo',
      BookingStartDate: start_date,
      BookingEndDate: end_date,
      IsExclusiveWithAll: true
    }}
    let(:result) do
      client.create_special(
        location_id: booker_location_id,
        start_date: start_date,
        end_date: end_date,
        coupon_code: coupon_code,
        name: name,
        params: params
      )
    end
    let(:expected_params) {{
      access_token: 'access_token',
      LocationID: booker_location_id,
      ApplicableStartDate: '/Date(1438675200000)/',
      ApplicableEndDate: '/Date(1438761599000)/',
      CouponCode: 'fred123456',
      Name: 'Frederick 20% Off',
      Type: 2,
      AdjustmentType: 1,
      DiscountType: 1,
      DiscountAmount: 20,
      MaxRedemptions: 1,
      Description: 'foo',
      BookingStartDate: Booker::V4::Models::Model.time_to_booker_datetime(start_date),
      BookingEndDate: Booker::V4::Models::Model.time_to_booker_datetime(end_date),
      IsExclusiveWithAll: true
    }}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:post).with('/v4.1/merchant/special', expected_params).and_return 'response'
    end

    it 'delegates to post' do
      expect(result).to eq 'response'
    end
  end
end
