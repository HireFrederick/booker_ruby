require 'spec_helper'

describe Booker::V5::Models::Availability do
  it { is_expected.to be_a Booker::V5::Models::Model }

  it 'has the correct attributes' do
    %w(startDateTime endDateTime employees).each do |attr|
      expect(subject).to respond_to(attr)
    end
  end

  describe '.from_hash' do
    let(:hash) do
      {
        'startDateTime' => '2016-12-29T16:00:00+00:00',
        'endDateTime' => '2016-12-29T22:30:00+00:00',
        'employees' => [3,4,5]
      }
    end
    let(:result) { described_class.from_hash(hash) }

    it 'converts times' do
      expect(result.startDateTime).to eq Time.parse('2016-12-29T16:00:00+00:00')
      expect(result.endDateTime).to eq Time.parse('2016-12-29T22:30:00+00:00')
      expect(result.employees).to eq [3,4,5]
    end
  end
end
