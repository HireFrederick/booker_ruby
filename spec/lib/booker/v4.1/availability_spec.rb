require 'spec_helper'

describe Booker::V41::Availability do
  let(:client) do
    Booker::V41::Availability.new(
      client_id: 'foo_client_id',
      client_secret: 'foo_client_secret',
    )
  end
  let(:booker_location_id) { 10257 }
  let(:response) { 'resp' }

  before { allow(client).to receive(:access_token).and_return 'access_token' }

  it { is_expected.to be_a Booker::Client }

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
        .with('/v4.1/availability/availability/class', expected_params, Booker::V4::Models::ClassInstance).and_return([])
    end

    it 'delegates to post' do
      expect(result).to eq []
    end

    context 'other params' do
      let(:params) {{another_param: 'foo'}}

      let(:expected_params) {{
        FromStartDateTime: '/Date(1438934400000)/',
        LocationID: 10257,
        OnlyIfAvailable: true,
        ToStartDateTime: '/Date(1439020799000)/',
        ExcludeClosedDates: true,
        access_token: 'access_token',
        another_param: 'foo'
      }}

      it 'merges the params passed in with base params' do
        expect(result).to eq []
      end
    end
  end
end
