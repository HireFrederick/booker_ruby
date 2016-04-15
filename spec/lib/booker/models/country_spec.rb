require 'spec_helper'

describe Booker::Models::Country do
  it { is_expected.to be_a(Booker::Models::Type) }

  describe 'constants' do
    let(:names_to_codes) { described_class::NAMES_TO_ISO_CODES }

    it 'sets constants to right vals' do
      expect(names_to_codes).to be_a Hash
      expect(names_to_codes.length).to eq 267
      names_to_codes.values.each do |country_code|
        expect(country_code.class).to eq String
        expect(country_code.length).to eq 2
        expect(Carmen::Country.coded(country_code)).to_not eq nil
      end
    end
  end

  describe '#country_code' do
    let(:country_name) { "Cote D'Ivoire (Ivory Coast)" }

    subject { described_class.new('Name' => country_name) }

    it('returns right country code for name') { expect(subject.country_code).to eq 'CI' }
  end
end
