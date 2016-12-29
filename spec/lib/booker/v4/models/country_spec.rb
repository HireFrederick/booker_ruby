require 'spec_helper'

describe Booker::V4::Models::Country do
  it { is_expected.to be_a(Booker::V4::Models::Type) }

  describe 'constants' do
    let(:ids_to_codes) { described_class::IDS_TO_ISO_CODES }

    it 'sets constants to right vals' do
      expect(ids_to_codes).to be_a Hash
      expect(ids_to_codes.length).to eq 268
      ids_to_codes.values.each do |country_code|
        expect(country_code.class).to eq String
        expect(country_code.length).to eq 2
      end
    end
  end

  describe '#country_code' do
    let(:country_id) { 69 }

    subject { described_class.new('ID' => country_id) }

    it('returns right country code for name') { expect(subject.country_code).to eq 'GB' }
  end

  describe '.from_country_code' do
    let(:country_code) { 'GB' }
    let(:result) { described_class.from_country_code('GB') }

    it 'returns country' do
      expect(result).to be_a(described_class)
      expect(result.ID).to be 69
    end

    context 'code not found' do
      let(:result) { described_class.from_country_code('FOO') }

      it 'raises ArgumentError' do
        expect{result}.to raise_error ArgumentError, 'Country code not recognized'
      end
    end
  end
end
