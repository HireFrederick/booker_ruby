require 'spec_helper'

describe Booker::V5::Models::LocationHour do
  it { is_expected.to be_a Booker::V5::Models::Model }

  it 'has the correct attributes' do
    %w(open close).each do |attr|
      expect(subject).to respond_to(attr)
    end
  end

  describe '.from_hash' do
    let(:hash) do
      {
        'open' => '2016-12-29T16:00:00+00:00',
        'close' => '2016-12-29T22:30:00+00:00',
      }
    end
    let(:result) { described_class.from_hash(hash) }

    it 'converts dates and times' do
      expect(result.open).to eq Time.parse('2016-12-29T16:00:00+00:00')
      expect(result.close).to eq Time.parse('2016-12-29T22:30:00+00:00')
    end
  end
end
