require 'spec_helper'

describe Booker::V41::Customer do
  let(:client) do
    Booker::V41::Customer.new(
      client_id: 'foo_client_id',
      client_secret: 'foo_client_secret',
    )
  end
  let(:booker_location_id) { 10257 }
  let(:response) { 'resp' }
  let(:v41_prefix) { '/v4.1/customer' }
  let(:v41_appointments_prefix) { '/v4.1/customer/appointment' }

  before { allow(client).to receive(:access_token).and_return 'access_token' }

  describe 'constants' do
    let(:api_methods) do
      {
        appointment: "#{v41_appointments_prefix}",
        cancel_appointment: "#{v41_appointments_prefix}/cancel",
        create_appointment: "#{v41_appointments_prefix}/create",
        create_class_appointment: "#{v41_prefix}/class_appointment/create",
        employees: "#{v41_prefix}/employees",
        treatments: "#{v41_prefix}/treatments",
        treatments_verified_bookable_online: "#{v41_prefix}/treatments/online",
        location: "#{v41_prefix}/location",
        locations: "#{v41_prefix}/locations",
        class_availability: "#{v41_prefix}/availability/class",
      }
    end

    it 'get set to the correct values' do
      expect(described_class::V41_PREFIX).to eq('/v4.1/customer')
      expect(described_class::V41_APPOINTMENTS_PREFIX).to eq('/v4.1/customer/appointment')
      expect(described_class::API_METHODS).to eq(api_methods)
    end
  end

  describe '#appointment' do
    let(:expected_params) { {access_token: 'access_token' } }

    before do
      expect(client).to receive(:get)
        .with('/v4.1/customer/appointment/123', expected_params, Booker::V4::Models::Appointment).and_return(response)
    end

    it 'returns appointment' do
      expect(client.appointment(id: 123)).to be response
    end
  end

  describe '#cancel_appointment' do
    let(:expected_params) do
      {
        access_token: 'access_token',
        ID: 123,
        another_option: 'foo'
      }
    end
    before do
      expect(client).to receive(:put)
        .with('/v4.1/customer/appointment/cancel', expected_params, Booker::V4::Models::Appointment).and_return(response)
    end

    it 'returns appointment' do
      expect(client.cancel_appointment(id: 123, params: {another_option: 'foo'})).to be response
    end
  end

  describe '#create_class_appointment' do
    let(:customer) { Booker::V4::Models::Customer.new(
      Address: Booker::V4::Models::Address.new(
        Street1: '680 Mission St',
        Street2: 'Apt 123',
        City: 'San Francisco',
        State: 'CA',
        Zip: '94105'
      ),
      DateOfBirth: Date.parse('1982-01-21'),
      Email: 'testasevers@example.com',
      FirstName: 'Aaron',
      LastName: 'Severs',
      GenderID: 1,
      MobilePhone: '555-555-5555',
      SendEmail: true
    ) }
    let(:result) { client.create_class_appointment(location_id: 10257, class_instance_id: 3944336, customer: customer) }
    let(:expected_params) {{
      LocationID: 10257,
      ClassInstanceID: 3944336,
      Customer: customer,
      access_token: 'access_token'
    }}

    before do
      expect(client).to receive(:post).with("#{v41_prefix}/class_appointment/create", expected_params, Booker::V4::Models::Appointment).and_return(Booker::V4::Models::Appointment.new)
    end

    it 'returns the appointment' do
      expect(result).to be_a Booker::V4::Models::Appointment
    end

    context 'other options' do
      let(:params) {{another_params: 'foo'}}

      let(:expected_params) {{
        LocationID: 10257,
        ClassInstanceID: 3944336,
        Customer: customer,
        access_token: 'access_token',
      }.merge(params)}
      let(:result) { client.create_class_appointment(location_id: 10257, class_instance_id: 3944336, customer: customer, params: params) }

      it 'adds other options passed in to the params' do
        expect(result).to be_a Booker::V4::Models::Appointment
      end
    end
  end

  describe '#create_appointment' do
    let(:available_time) { Booker::V4::Models::AvailableTime.new(
      CurrentPrice: Booker::V4::Models::CurrentPrice.new(Amount: 125.0, CurrencyCode: 'USD'),
      Duration: 60,
      EmployeeID: 107269,
      StartDateTime: '/Date(1438776000000)/',
      TreatmentID: 560069
    )}

    let(:customer) { Booker::V4::Models::Customer.new(
      Address: Booker::V4::Models::Address.new(
        Street1: '680 Mission St',
        Street2: 'Apt 123',
        City: 'San Francisco',
        State: 'CA',
        Zip: '94105'
      ),
      DateOfBirth: Date.parse('1982-01-21'),
      Email: 'testasevers@example.com',
      FirstName: 'Aaron',
      LastName: 'Severs',
      GenderID: 1,
      MobilePhone: '555-555-5555',
      SendEmail: true
    ) }
    let(:result) { client.create_appointment(location_id: 10257, available_time: available_time, customer: customer) }
    let(:expected_params) {{
      LocationID: 10257,
      ItineraryTimeSlotList: [
        TreatmentTimeSlots: [available_time]
      ],
      Customer: customer,
      access_token: 'access_token'
    }}

    before do
      expect(client).to receive(:post)
        .with('/v4.1/customer/appointment/create', expected_params, Booker::V4::Models::Appointment)
                          .and_return(Booker::V4::Models::Appointment.new)
    end

    it 'returns the appointment' do
      expect(result).to be_a Booker::V4::Models::Appointment
    end

    context 'other params' do
      let(:params) {{another_option: 'foo'}}

      let(:expected_params) {{
        LocationID: 10257,
        ItineraryTimeSlotList: [
          TreatmentTimeSlots: [available_time]
        ],
        Customer: customer,
        access_token: 'access_token',
      }.merge(params)}
      let(:result) do
        client.create_appointment(
          location_id: 10257, available_time: available_time, customer: customer, params: params
        )
      end

      it 'merges passed in params into base params' do
        expect(result).to be_a Booker::V4::Models::Appointment
      end
    end
  end

  describe '#employees' do
    let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
      access_token: 'access_token',
      LocationID: booker_location_id
    })}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:paginated_request).with(
        method: :post,
        path: '/v4.1/customer/employees',
        params: expected_params,
        model: Booker::V4::Models::Employee,
        fetch_all: true
      ).and_return([])
    end

    it 'delegates to get_booker_resources' do
      expect(client.employees(location_id: booker_location_id)).to eq []
    end

    context 'other params' do
      let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
        access_token: 'access_token',
        LocationID: booker_location_id,
        another_option: 'foo'
      })}

      it 'merges passed in params into base params' do
        expect(client.employees(location_id: booker_location_id, params: {another_option: 'foo'})).to eq []
      end
    end
  end

  describe '#location' do
    let(:booker_location_id) { 123 }
    let(:result) { client.location(id: booker_location_id) }
    let(:expected_params) {{
      access_token: 'access_token'
    }}
    let(:response) {{
      ID: booker_location_id
    }}

    before do
      expect(client).to receive(:get)
                          .with("/v4.1/customer/location/#{booker_location_id}", expected_params).and_return(response)
    end

    it 'delegates to get and returns' do
      expect(result).to be_a Booker::V4::Models::Location
      expect(result.ID).to be booker_location_id
    end
  end

  describe '#locations' do
    let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
      access_token: 'access_token'
    })}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:paginated_request).with(
        method: :post,
        path: '/v4.1/customer/locations',
        params: expected_params,
        model: Booker::V4::Models::Location
      ).and_return([])
    end

    it 'delegates to paginated_request' do
      expect(client.locations).to eq []
    end

    context 'other params' do
      let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
        access_token: 'access_token',
        another_option: 'foo'
      })}

      it 'merges passed in params into base params' do
        expect(client.locations(params: {another_option: 'foo'})).to eq []
      end
    end
  end

  describe '#treatment' do
    let(:expected_params) { {access_token: 'access_token' } }

    before do
      expect(client).to receive(:get)
                          .with('/v4.1/customer/treatment/123', expected_params, Booker::V4::Models::TreatmentVerifiedBookableOnline).and_return(response)
    end

    it 'returns appointment' do
      expect(client.treatmemt(id: 123)).to be response
    end
  end

  describe '#treatments' do
    let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
      access_token: 'access_token',
      LocationID: booker_location_id
    })}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:paginated_request).with(
        method: :post,
        path: '/v4.1/customer/treatments',
        params: expected_params,
        model: Booker::V4::Models::Treatment,
        fetch_all: true
      ).and_return([])
    end

    it 'delegates to get_booker_resources' do
      expect(client.treatments(location_id: booker_location_id)).to eq []
    end

    context 'other params' do
      let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
        access_token: 'access_token',
        LocationID: booker_location_id,
        another_option: 'foo'
      })}

      it 'merges passed in params into base params' do
        expect(client.treatments(location_id: booker_location_id, params: {another_option: 'foo'})).to eq []
      end
    end
  end

  describe '#treatments_verified_bookable_online' do
    let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
      access_token: 'access_token',
      LocationID: booker_location_id
    })}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:paginated_request).with(
        method: :post,
        path: '/v4.1/customer/treatments/online',
        params: expected_params,
        model: Booker::V4::Models::TreatmentVerifiedBookableOnline,
        fetch_all: true
      ).and_return([])
    end

    it 'delegates to get_booker_resources' do
      expect(client.treatments_verified_bookable_online(location_id: booker_location_id)).to eq []
    end

    context 'other params' do
      let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
        access_token: 'access_token',
        LocationID: booker_location_id,
        another_option: 'foo'
      })}

      it 'merges passed in params into base params' do
        expect(
          client.treatments_verified_bookable_online(location_id: booker_location_id, params: { another_option: 'foo' })
        ).to eq []
      end
    end
  end

  describe '#run_class_availability' do
    let(:params) {{}}
    let(:result) { client.class_availability(
      location_id: 10257,
      from_start_date_time: Time.zone.parse('2015-08-07 00:00:00 -0400'),
      to_start_date_time: Time.zone.parse('2015-08-07 23:59:59 -0400'),
      params: params
    ) }
    let(:expected_params) {{
      FromStartDateTime: '/Date(1438934400000)/',
      LocationID: 10257,
      OnlyIfAvailable: true,
      ToStartDateTime: '/Date(1439020799000)/',
      ExcludeClosedDates: true,
      access_token: 'access_token'
    }}

    before do
      expect(client).to receive(:post)
        .with('/v4.1/customer/availability/class', expected_params, Booker::V4::Models::ClassInstance).and_return([])
    end

    it 'delegates to post' do
      expect(result).to eq []
    end

    context 'other params' do
      let(:params) {{another_param: 'foo'}}

      let(:expected_params) {{
        access_token: 'access_token',
        FromStartDateTime: '/Date(1438934400000)/',
        LocationID: 10257,
        OnlyIfAvailable: true,
        ToStartDateTime: '/Date(1439020799000)/',
        ExcludeClosedDates: true,
        another_param: 'foo'
      }}

      it 'merges the params passed in with base params' do
        expect(result).to eq []
      end
    end
  end
end
