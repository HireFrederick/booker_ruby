require 'spec_helper'

describe Booker::V4::Models::Model do
  let(:active_support_timezone_name) { 'International Date Line West' }

  it { is_expected.to be_a Booker::Model }

  it { expect(described_class::CONSTANTIZE_MODULE).to be Booker::V4::Models }

  describe '#to_hash converts times to Booker times' do
    let(:model) { described_class.new }
    let(:time) { Time.now }
    let(:date) { Date.today }
    let(:result) { model.to_hash }

    before do
      model.instance_variable_set :@attributes, [:time, :date]
      allow(model).to receive(:time).and_return time
      allow(model).to receive(:date).and_return date
    end

    it 'converts booker times' do
      expect(result[:time]).to start_with('/Date')
      expect(result[:date]).to start_with('/Date')
    end
  end

  describe '.from_hash parses Booker times' do
    let(:model) do
      described_class.from_hash({
        SomeDate: '/Date(380437200000-0500)/'
      })
    end

    before do
      allow_any_instance_of(described_class).to receive(:SomeDate)
      expect_any_instance_of(described_class).to receive(:SomeDate=).with(Time.zone.parse('1982-01-21 00:00:00 +0000'))
    end

    it 'creates a model from the hash' do
      expect(model).to be_a described_class
    end
  end

  describe '.time_from_booker_datetime' do
    it 'converts the Booker datetime format to a time object in the current timzone AS IF it was eastern time' do
      expect(described_class.time_from_booker_datetime('/Date(380437200000-0500)/')).to eq Time.zone.parse('1982-01-21 00:00:00 -00:00')
    end
  end

  describe '.time_to_booker_datetime' do
    it 'converts the time to a Booker datetime string' do
      expect(described_class.time_to_booker_datetime(Time.parse('1982-01-21 00:00:00 +0000'))).to eq '/Date(380437200000)/'
      expect(described_class.time_to_booker_datetime(Time.parse('1982-01-21 00:00:00 +1200'))).to eq '/Date(380437200000)/'
    end
  end

  describe '.timezone_from_booker_timezone' do
    let(:result) { described_class.timezone_from_booker_timezone(booker_timezone_name) }

    before do
      expect(Booker::Helpers::ActiveSupport).to receive(:to_active_support)
                                                    .with(booker_timezone_name)
                                                    .and_call_original
    end

    context 'booker_timezone_name can be mapped to active support time zone' do
      let(:booker_timezone_name) { '(GMT-09:00) Alaska' }

      before do
        expect(Booker::Helpers::LoggingHelper).to_not receive(:log_issue)
        expect(described_class).to_not receive(:timezone_from_booker_offset!)
      end

      it('returns active support time zone') { expect(result).to eq 'Alaska' }
    end

    context 'offset from booker_timezone_name can be mapped to active support time zone' do
      let(:booker_offset_match) { '(GMT-12:00' }
      let(:booker_timezone_name) { "#{booker_offset_match}) FOOBAR" }
      let(:booker_timezone_map_key) { "#{booker_offset_match}) #{active_support_timezone_name}" }
      let(:mock_return_method) { [:and_call_original] }

      before do
        expect(described_class).to receive(:timezone_from_booker_offset!).with(booker_timezone_name).and_call_original
        expect(Booker::Helpers::ActiveSupport).to receive(:to_active_support)
                                                      .with(booker_timezone_map_key)
                                                      .and_call_original
        expect(Booker::Helpers::LoggingHelper).to receive(:log_issue)
                                                      .with(
                                                          'Unable to find time zone name using Booker::Helpers::ActiveSupport.to_active_support',
                                                          booker_timezone_name: booker_timezone_name
                                                      ).send(*mock_return_method)
      end

      it('returns active support time zone') { expect(result).to eq active_support_timezone_name }

      context 'booker logger does raise' do
        let(:mock_return_method) { [:and_raise, StandardError] }

        it('returns active support time zone') { expect(result).to eq active_support_timezone_name }
      end
    end

    context 'has non matching booker timezone name' do
      let(:booker_timezone_name) { 'foo' }

      before do
        expect(described_class).to receive(:timezone_from_booker_offset!).with(booker_timezone_name).and_call_original
        expect(Booker::Helpers::LoggingHelper).to receive(:log_issue)
                                                      .with(
                                                          'Unable to find time zone name using Booker::Helpers::ActiveSupport.to_active_support',
                                                          booker_timezone_name: booker_timezone_name
                                                      )
                                                      .and_call_original
      end

      it('raises Booker Error') { expect { result }.to raise_error Booker::Error }
    end
  end

  describe '.timezone_from_booker_offset!' do
    let(:booker_offset_match) { '(GMT-12:00' }
    let(:booker_timezone_name) { "#{booker_offset_match}) FOOBAR" }
    let(:booker_timezone_map_key) { "#{booker_offset_match}) #{active_support_timezone_name}" }
    let(:result) { described_class.timezone_from_booker_offset!(booker_timezone_name) }

    context 'booker_offset match found' do
      context 'match does map to active support' do
        before do
          expect(Booker::Helpers::ActiveSupport).to receive(:booker_timezone_names).with(no_args).and_call_original
          expect(Booker::Helpers::ActiveSupport).to receive(:to_active_support).with(booker_timezone_map_key).and_call_original
        end

        it('returns active support timezone') { expect(result).to eq active_support_timezone_name }
      end

      context 'match does not map to active support' do
        let(:booker_offset_match) { '(GMT-120000:00' }

        before do
          expect(Booker::Helpers::ActiveSupport).to receive(:booker_timezone_names).with(no_args).and_call_original
          expect(Booker::Helpers::ActiveSupport).to_not receive(:to_active_support)
        end

        it 'raises Booker::Error' do
          expect {
            result
          }.to raise_error Booker::Error
        end
      end

      context 'match is blank' do
        let(:booker_timezone_name) { " ) " }

        before do
          expect(Booker::Helpers::ActiveSupport).to_not receive(:booker_timezone_names)
          expect(Booker::Helpers::ActiveSupport).to_not receive(:to_active_support)
        end

        it 'raises Booker::Error' do
          expect {
            result
          }.to raise_error Booker::Error
        end
      end
    end

    context 'no match' do
      let(:booker_timezone_name) { "#{booker_offset_match} FOOBAR" }

      it 'raises Booker::Error' do
        expect {
          result
        }.to raise_error Booker::Error
      end
    end
  end

  describe '.to_wday' do
    let(:booker_wday) { 'Friday' }

    before { expect(Date).to receive(:parse).with(booker_wday).and_call_original }

    it('returns wday') { expect(described_class.to_wday(booker_wday)).to eq 5 }
  end
end
