require 'spec_helper'

describe Booker::V4::CommonREST do
  let(:client) do
    Booker::V4::CustomerClient.new(
      client_id: 'foo_client_id',
      client_secret: 'foo_client_secret'
    )
  end

  describe '#get_online_booking_settings' do
    let(:options) {{}}
    let(:result) { client.get_online_booking_settings(booker_location_id: 10257) }
    let(:expected_params) {{
      'access_token' => 'access_token'
    }}
    let(:response) {{
      'OnlineBookingSettings' => {
        'RequireCustomerGender' => true
      }
    }}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:get).with('/location/10257/online_booking_settings', expected_params).and_return(response)
    end

    it 'delegates to get and returns the OnlineBookingSettings from the response' do
      expect(result).to be_a Booker::V4::Models::OnlineBookingSettings
      expect(result.RequireCustomerGender).to be true
    end
  end

  describe '#confirm_appointment' do
    let(:options) {{}}
    let(:result) { client.confirm_appointment(appointment_id: 98864422) }
    let(:expected_params) {{
      'ID' => 98864422,
      'access_token' => 'access_token'
    }}
    let(:response) {{
      'Appointment' => {
        'ID' => 98864422
      }
    }}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:put).with('/appointment/confirm', expected_params, Booker::V4::Models::Appointment).and_return(response)
    end

    it 'delegates to put and returns' do
      expect(result).to eq response
    end
  end

  describe '#get_location' do
    let(:booker_location_id) { 123 }
    let(:result) { client.get_location(booker_location_id: booker_location_id) }
    let(:expected_params) {{
      'access_token' => 'access_token'
    }}
    let(:response) {{
      'ID' => booker_location_id
    }}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:get).with("/location/#{booker_location_id}", expected_params).and_return(response)
    end

    it 'delegates to get and returns' do
      expect(result).to be_a Booker::V4::Models::Location
      expect(result.ID).to be booker_location_id
    end
  end
end
