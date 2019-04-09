require 'spec_helper'

describe Booker::V5::InternalClient do
  let(:client) { described_class.new }

  it { is_expected.to be_a(Booker::Client) }

  describe 'includes' do
    it 'Booker::RequestHelper' do
      expect(described_class.ancestors).to include(Booker::RequestHelper)
    end
  end

  describe 'constants' do
    it 'sets constants to right values' do
      expect(described_class::V5_PREFIX).to eq('/v5')
      expect(described_class::V5_INTERNAL_LOCATIONS_PREFIX).to eq('/v5/internal/locations')
    end
  end

  describe '#purchased_series' do
    let(:location_id) { 456 }
    let(:filters) { { 'customer-id' => 123 } }
    let(:location_uri) { 'location_uri' }
    let(:build_params) { { name: 'value' } }
    let(:merged_params) { build_params.merge('filter' => filters) }
    let(:response) { 'response' }
    let(:result) { client.purchased_series(location_id, filters) }

    before do
      expect(client).to receive(:location_uri).with(location_id, 'purchased-series').and_return(location_uri)
      expect(client).to receive(:build_params).and_return(build_params)
      expect(client).to receive(:get)
                          .with(location_uri, merged_params, Booker::V5::Models::PurchasedSeries)
                          .and_return(response)
    end

    it 'delegates to get and returns' do
      expect(result).to eq(response)
    end
  end

  describe 'private#location_uri' do
    let(:location_id) { 456 }
    let(:method_name) { 'purchased_series' }
    let(:result) { client.send(:location_uri, location_id, method_name) }

    it 'returns valid uri' do
      expect(result).to eq('/v5/internal/locations/456/purchased_series')
    end
  end
end
