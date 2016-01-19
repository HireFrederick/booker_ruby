require 'spec_helper'

describe Booker::CommonREST do
  let(:client) { TestClient.customer_client }

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
      expect(result).to be_a Booker::Models::OnlineBookingSettings
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
      expect(client).to receive(:put).with('/appointment/confirm', expected_params, Booker::Models::Appointment).and_return(response)
    end

    it 'delegates to put and returns' do
      expect(result).to eq response
    end
  end
end
