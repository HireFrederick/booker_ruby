require 'spec_helper'

describe Booker::V5::Availability do
  let(:client) { described_class.new }
  it { is_expected.to be_a(Booker::Client) }

  describe '#availability' do
    let(:location_ids) { [456] }
    let(:from_date_time) { 'from_date_time' }
    let(:to_date_time) { 'to_date_time' }
    let(:result) { client.availability(location_ids: location_ids, from_date_time: from_date_time, to_date_time: to_date_time) }
    let(:expected_params) {{
      locationIds: location_ids,
      fromDateTime: from_date_time,
      toDateTime: to_date_time,
      includeEmployees: true
    }}
    let(:response) { 'resp' }

    before do
      expect(client).to receive(:get)
        .with('/v5/availability/availability', expected_params, Booker::V5::Models::AvailabilityResult)
        .and_return(response)
    end

    it 'delegates to get and returns' do
      expect(result).to be response
    end
  end
end
