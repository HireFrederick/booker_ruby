require 'spec_helper'

describe Booker::V4::CustomerREST do
  let(:client) do
    Booker::V4::CustomerClient.new(
      client_id: 'foo_client_id',
      client_secret: 'foo_client_secret'
    )
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
    let(:result) { client.create_appointment(booker_location_id: 10257, available_time: available_time, customer: customer) }
    let(:expected_params) {{
        :'LocationID' => 10257,
        :'ItineraryTimeSlotList' => [
            'TreatmentTimeSlots' => [available_time]
        ],
        :'Customer' => customer,
        :'access_token' => 'access_token'
    }}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:post).with('/appointment/create', expected_params, Booker::V4::Models::Appointment).and_return(Booker::V4::Models::Appointment.new)
    end

    it 'returns the appointment' do
      expect(result).to be_a Booker::V4::Models::Appointment
    end

    context 'other options' do
      let(:options) {{:'another_option' => 'foo'}}

      let(:expected_params) {{
          :'LocationID' => 10257,
          :'ItineraryTimeSlotList' => [
              'TreatmentTimeSlots' => [available_time]
          ],
          :'Customer' => customer,
          :'access_token' => 'access_token',
      }.merge(options)}
      let(:result) { client.create_appointment(booker_location_id: 10257, available_time: available_time, customer: customer, options: options) }

      it 'adds other options passed in to the params' do
        expect(result).to be_a Booker::V4::Models::Appointment
      end
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
    let(:result) { client.create_class_appointment(booker_location_id: 10257, class_instance_id: 3944336, customer: customer) }
    let(:expected_params) {{
      LocationID: 10257,
      ClassInstanceID: 3944336,
      Customer: customer,
      access_token: 'access_token'
    }}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:post).with('/class_appointment/create', expected_params, Booker::V4::Models::Appointment).and_return(Booker::V4::Models::Appointment.new)
    end

    it 'returns the appointment' do
      expect(result).to be_a Booker::V4::Models::Appointment
    end

    context 'other options' do
      let(:options) {{another_option: 'foo'}}

      let(:expected_params) {{
        LocationID: 10257,
        ClassInstanceID: 3944336,
        Customer: customer,
        access_token: 'access_token',
      }.merge(options)}
      let(:result) { client.create_class_appointment(booker_location_id: 10257, class_instance_id: 3944336, customer: customer, options: options) }

      it 'adds other options passed in to the params' do
        expect(result).to be_a Booker::V4::Models::Appointment
      end
    end
  end
end
