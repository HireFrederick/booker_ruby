require 'spec_helper'

describe Booker::V41::Booking do
  let(:client) do
    Booker::V41::Booking.new(
      client_id: 'foo_client_id',
      client_secret: 'foo_client_secret',
    )
  end
  let(:booker_location_id) { 10257 }
  let(:response) { 'resp' }

  before { allow(client).to receive(:access_token).and_return 'access_token' }

  describe 'constants' do
    let(:v41_prefix) { '/v4.1/booking' }
    let(:v41_appointments_prefix) { '/v4.1/booking/appointment' }
    let(:api_methods) do
      {
        appointment: "#{v41_appointments_prefix}",
        cancel_appointment: "#{v41_appointments_prefix}/cancel",
        create_appointment: "#{v41_appointments_prefix}/create",
        appointment_hold: "#{v41_appointments_prefix}/hold",
        employees: "#{v41_prefix}/employees",
        services: "#{v41_prefix}/services",
        location: "#{v41_prefix}/location",
        locations: "#{v41_prefix}/locations"
      }
    end

    it 'get set to the correct values' do
      expect(described_class::V41_PREFIX).to eq('/v4.1/booking')
      expect(described_class::V41_APPOINTMENTS_PREFIX).to eq('/v4.1/booking/appointment')
      expect(described_class::API_METHODS).to eq(api_methods)
    end
  end

  describe '#appointment' do
    let(:expected_params) { {access_token: 'access_token' } }

    before do
      expect(client).to receive(:get)
        .with('/v4.1/booking/appointment/123', expected_params, Booker::V4::Models::Appointment).and_return(response)
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
        .with('/v4.1/booking/appointment/cancel', expected_params, Booker::V4::Models::Appointment).and_return(response)
    end

    it 'returns appointment' do
      expect(client.cancel_appointment(id: 123, params: {another_option: 'foo'})).to be response
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
        .with('/v4.1/booking/appointment/create', expected_params, Booker::V4::Models::Appointment)
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

  describe '#create_appointment_hold' do
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
    let(:result) { client.create_appointment_hold(location_id: 10257, available_time: available_time, customer: customer) }
    let(:expected_params) {{
      LocationID: 10257,
      ItineraryTimeSlot: {
        TreatmentTimeSlots: [available_time]
      },
      Customer: customer,
      access_token: 'access_token'
    }}

    before do
      expect(client).to receive(:post)
                          .with('/v4.1/booking/appointment/hold', expected_params)
                          .and_return(response)
    end

    it 'returns the appointment' do
      expect(result).to be response
    end

    context 'other params' do
      let(:params) {{another_option: 'foo'}}

      let(:expected_params) {{
        LocationID: 10257,
        ItineraryTimeSlot: {
          TreatmentTimeSlots: [available_time]
        },
        Customer: customer,
        access_token: 'access_token',
      }.merge(params)}
      let(:result) do
        client.create_appointment_hold(
          location_id: 10257, available_time: available_time, customer: customer, params: params
        )
      end

      it 'merges passed in params into base params' do
        expect(result).to be response
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
        path: '/v4.1/booking/employees',
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
                          .with("/v4.1/booking/location/#{booker_location_id}", expected_params).and_return(response)
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
        path: '/v4.1/booking/locations',
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

  describe '#services' do
    let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
      access_token: 'access_token',
      LocationID: booker_location_id
    })}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:paginated_request).with(
        method: :post,
        path: '/v4.1/booking/services',
        params: expected_params,
        model: Booker::V4::Models::Treatment,
        fetch_all: true
      ).and_return([])
    end

    it 'delegates to get_booker_resources' do
      expect(client.services(location_id: booker_location_id)).to eq []
    end

    context 'other params' do
      let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
        access_token: 'access_token',
        LocationID: booker_location_id,
        another_option: 'foo'
      })}

      it 'merges passed in params into base params' do
        expect(client.services(location_id: booker_location_id, params: {another_option: 'foo'})).to eq []
      end
    end
  end
end
