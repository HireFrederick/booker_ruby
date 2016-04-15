require 'spec_helper'

describe Booker::CustomerREST do
  let(:client) { TestClient.customer_client }

  describe '#create_appointment' do
    let(:available_time) { Booker::Models::AvailableTime.new(
      CurrentPrice: Booker::Models::CurrentPrice.new(Amount: 125.0, CurrencyCode: 'USD'),
      Duration: 60,
      EmployeeID: 107269,
      StartDateTime: '/Date(1438776000000)/',
      TreatmentID: 560069
    )}

    let(:customer) { Booker::Models::Customer.new(
      Address: Booker::Models::Address.new(
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
      'LocationID' => 10257,
      'ItineraryTimeSlotList' => [
        'TreatmentTimeSlots' => [available_time]
      ],
      'Customer' => customer,
      'access_token' => 'access_token'
    }}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:post).with('/appointment/create', expected_params, Booker::Models::Appointment).and_return(Booker::Models::Appointment.new)
    end

    it 'returns the appointment' do
      expect(result).to be_a Booker::Models::Appointment
    end

    context 'other options' do
      let(:options) {{'another_option' => 'foo'}}

      let(:expected_params) {{
        'LocationID' => 10257,
        'ItineraryTimeSlotList' => [
          'TreatmentTimeSlots' => [available_time]
        ],
        'Customer' => customer,
        'access_token' => 'access_token',
      }.merge(options)}
      let(:result) { client.create_appointment(booker_location_id: 10257, available_time: available_time, customer: customer, options: options) }

      it 'adds other options passed in to the params' do
        expect(result).to be_a Booker::Models::Appointment
      end
    end
  end

  describe '#create_class_appointment' do
    let(:customer) { Booker::Models::Customer.new(
      Address: Booker::Models::Address.new(
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
      'LocationID' => 10257,
      'ClassInstanceID' => 3944336,
      'Customer' => customer,
      'access_token' => 'access_token'
    }}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:post).with('/class_appointment/create', expected_params, Booker::Models::Appointment).and_return(Booker::Models::Appointment.new)
    end

    it 'returns the appointment' do
      expect(result).to be_a Booker::Models::Appointment
    end

    context 'other options' do
      let(:options) {{'another_option' => 'foo'}}

      let(:expected_params) {{
        'LocationID' => 10257,
        'ClassInstanceID' => 3944336,
        'Customer' => customer,
        'access_token' => 'access_token',
      }.merge(options)}
      let(:result) { client.create_class_appointment(booker_location_id: 10257, class_instance_id: 3944336, customer: customer, options: options) }

      it 'adds other options passed in to the params' do
        expect(result).to be_a Booker::Models::Appointment
      end
    end
  end

  describe '#run_multi_spa_multi_sub_category_availability' do
    let(:options) {{}}
    let(:result) do
      client.run_multi_spa_multi_sub_category_availability(
          booker_location_ids: [10257],
          treatment_sub_category_ids: [89],
          start_date_time: Time.zone.parse('2015-08-02 00:00:00 -0400'),
          end_date_time: Time.zone.parse('2015-08-02 23:59:59 -0400'),
          options: options
      )
    end
    let(:expected_params) {{
        'LocationIDs' => [10257],
        'TreatmentSubCategoryIDs' => [89],
        'StartDateTime' => '/Date(1438502400000)/',
        'EndDateTime' => '/Date(1438588799000)/',
        'MaxTimesPerTreatment' => 1000,
        'access_token' => 'access_token'
      }}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:post).with('/availability/multispamultisubcategory', expected_params, Booker::Models::SpaEmployeeAvailabilitySearchItem).and_return([])
    end

    it 'delegates to post' do
      expect(result).to eq []
    end

    context 'other options' do
      let(:options) {{'another_option' => 'foo'}}

      let(:expected_params) {{
        'LocationIDs' => [10257],
        'TreatmentSubCategoryIDs' => [89],
        'StartDateTime' => '/Date(1438502400000)/',
        'EndDateTime' => '/Date(1438588799000)/',
        'MaxTimesPerTreatment' => 1000,
        'access_token' => 'access_token',
        'another_option' => 'foo'
        }}

      it 'adds other options passed in to the params' do
        expect(result).to eq []
      end
    end
  end

  describe '#run_multi_service_availability' do
    let(:options) {{}}
    let(:result) do
      client.run_multi_service_availability(
        booker_location_id: 10257,
        treatment_ids: [123],
        start_date_time: Time.zone.parse('2015-08-02 00:00:00 -0400'),
        end_date_time: Time.zone.parse('2015-08-02 23:59:59 -0400'),
        options: options
      )
    end
    let(:expected_params) {{
      'LocationID' => 10257,
      'StartDateTime' => '/Date(1438502400000)/',
      'EndDateTime' => '/Date(1438588799000)/',
      'MaxTimesPerDay' => 100,
      'Itineraries' => [{'Treatments' => [{'TreatmentID' => 123}]}],
      'access_token' => 'access_token'
    }}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:post).with('/availability/multiservice', expected_params, Booker::Models::MultiServiceAvailabilityResult).and_return([])
    end

    it 'delegates to post' do
      expect(result).to eq []
    end

    context 'other options' do
      let(:options) {{'another_option' => 'foo'}}

      let(:expected_params) {{
        'LocationID' => 10257,
        'StartDateTime' => '/Date(1438502400000)/',
        'EndDateTime' => '/Date(1438588799000)/',
        'MaxTimesPerDay' => 100,
        'Itineraries' => [{'Treatments' => [{'TreatmentID' => 123}]}],
        'access_token' => 'access_token',
        'another_option' => 'foo'
      }}

      it 'adds other options passed in to the params' do
        expect(result).to eq []
      end
    end
  end

  describe '#run_class_availability' do
    let(:options) {{}}
    let(:result) { client.run_class_availability(
        booker_location_id: 10257,
        from_start_date_time: Time.zone.parse('2015-08-07 00:00:00 -0400'),
        to_start_date_time: Time.zone.parse('2015-08-07 23:59:59 -0400'),
        options: options
    ) }
    let(:expected_params) {{
      'FromStartDateTime' => '/Date(1438934400000)/',
      'LocationID' => 10257,
      'OnlyIfAvailable' => true,
      'ToStartDateTime' => '/Date(1439020799000)/',
      'ExcludeClosedDates' => true,
      'access_token' => 'access_token'
    }}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:post).with('/availability/class', expected_params, Booker::Models::ClassInstance).and_return([])
    end

    it 'delegates to post' do
      expect(result).to eq []
    end

    context 'other options' do
      let(:options) {{'another_option' => 'foo'}}

      let(:expected_params) {{
        'FromStartDateTime' => '/Date(1438934400000)/',
        'LocationID' => 10257,
        'OnlyIfAvailable' => true,
        'ToStartDateTime' => '/Date(1439020799000)/',
        'ExcludeClosedDates' => true,
        'access_token' => 'access_token',
        'another_option' => 'foo'
      }}

      it 'adds other options passed in to the params' do
        expect(result).to eq []
      end
    end
  end
end
