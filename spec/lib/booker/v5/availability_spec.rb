require 'spec_helper'

describe Booker::V5::Availability do
  let(:client) { described_class.new }
  it { is_expected.to be_a(Booker::Client) }

  describe '#search' do
    let(:location_ids) { [456] }
    let(:from_date_time) { 'from_date_time' }
    let(:to_date_time) { 'to_date_time' }
    let(:result) { client.search(location_ids: location_ids, from_date_time: from_date_time, to_date_time: to_date_time) }
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

    context 'with a service id specified' do
      let(:service_id) { 'service_id' }
      let(:expected_params) do
        {
          locationIds: location_ids,
          fromDateTime: from_date_time,
          toDateTime: to_date_time,
          includeEmployees: true,
          serviceId: service_id
        }
      end
      let(:result) do
        client.search(
          location_ids: location_ids,
          from_date_time: from_date_time,
          to_date_time: to_date_time,
          service_id: service_id
        )
      end

      it 'delegates to get and returns' do
        expect(result).to be response
      end
    end
  end

  describe '#two_day' do
    let(:location_id) { 456 }
    let(:from_date_time) { 'from_date_time' }
    let(:to_date_time) { 'to_date_time' }
    let(:result) { client.two_day(location_id: location_id, from_date_time: from_date_time) }
    let(:expected_params) {{
      locationId: location_id,
      fromDateTime: from_date_time,
      includeEmployees: true
    }}
    let(:response) { 'resp' }

    before do
      expect(client).to receive(:get)
                          .with('/v5/availability/2day', expected_params, Booker::V5::Models::AvailabilityResult)
                          .and_return(response)
    end

    it 'delegates to get and returns' do
      expect(result).to be response
    end
  end

  describe '#thirty_day' do
    let(:location_id) { 456 }
    let(:from_date_time) { 'from_date_time' }
    let(:to_date_time) { 'to_date_time' }
    let(:result) { client.thirty_day(location_id: location_id, from_date_time: from_date_time) }
    let(:expected_params) {{
      locationId: location_id,
      fromDateTime: from_date_time,
      includeEmployees: true
    }}
    let(:response) { 'resp' }

    before do
      expect(client).to receive(:get)
                          .with('/v5/availability/30day', expected_params, Booker::V5::Models::AvailabilityResult)
                          .and_return(response)
    end

    it 'delegates to get and returns' do
      expect(result).to be response
    end
  end
end
