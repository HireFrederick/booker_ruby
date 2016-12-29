require 'spec_helper'

describe Booker::V4::Models::LocationDaySchedule do
  it { is_expected.to be_a Booker::V4::Models::Model }

  it 'has the correct attributes' do
    [
        'Weekday',
        'StartTime',
        'EndTime'
    ].each do |attr|
      expect(subject).to respond_to(attr)
      expect(subject).to respond_to("#{attr}=")
    end
  end

  describe '.from_hash' do
    let(:start_time) { Time.parse('2014-01-09') }
    let(:end_time) { Time.parse('2014-01-10') }
    let(:weekday) { 'Sunday' }
    let(:hash) { {'Weekday' => weekday, 'StartTime' => start_time, 'EndTime' => end_time} }
    let(:strftime_format) { '%T' }
    let(:model) do
      described_class.new(
          'Weekday' => 0,
          'StartTime' => start_time.strftime(strftime_format),
          'EndTime' => end_time.strftime(strftime_format))
    end
    let(:result) { described_class.from_hash(hash) }

    before { expect(described_class).to receive(:to_wday).with(weekday).and_call_original }

    it 'converts hash to this model' do
      expect(result).to be_a described_class
      expect(result.Weekday).to eq 0
      expect(result.StartTime).to eq start_time.strftime(strftime_format)
      expect(result.EndTime).to eq end_time.strftime(strftime_format)
    end

    describe 'nil start time and end times' do
      let(:start_time) { nil }
      let(:end_time) { nil }

      it 'converts hash to this model without times' do
        expect(result).to be_a described_class
        expect(result.Weekday).to eq 0
        expect(result.StartTime).to eq nil
        expect(result.EndTime).to eq nil
      end
    end
  end
end
