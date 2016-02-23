require 'spec_helper'

describe Booker::Models::Model do
  let(:active_support_timezone_name) { 'International Date Line West' }

  describe '#initialize' do
    let(:model) { Booker::Models::Model.new(:x => 'y', :a => 'b') }

    it 'calls .send for each key-value specified' do
      expect_any_instance_of(Booker::Models::Model).to receive(:x=).with('y')
      expect_any_instance_of(Booker::Models::Model).to receive(:a=).with('b')
      model
    end
  end

  describe '#to_json' do
    let(:model) { Booker::Models::Model.new }

    before do
      model.instance_variable_set('@x', 'y')
    end

    it 'returns a json hash of all instance variables, but without the @' do
      expect(JSON.parse(model.to_json)['x']).to eq 'y'
    end
  end

  describe '#to_hash' do
    let(:model) { Booker::Models::Model.new }

    before do
      model.instance_variable_set('@x', 'y')
      model.instance_variable_set('@time', Time.now)
      model.instance_variable_set('@date', Date.today)
    end

    it 'returns a json hash of all instance variables, but without the @' do
      expect(model.to_hash['x']).to eq 'y'
      expect(model.to_hash['time']).to be_a String
      expect(model.to_hash['date']).to be_a String
    end
  end

  describe '.from_hash' do
    let(:model) {
      Booker::Models::Model.from_hash({
          x: 'y',
          SomeDate: '/Date(380437200000-0500)/',
          'Location' => {
            a: 'b'
          },
          'Locations': [{
              c: 'd'
            }],
          'Addresses': [123,456],
          'Address': nil
        })
    }

    before do
      allow_any_instance_of(Booker::Models::Model).to receive(:x)
      allow_any_instance_of(Booker::Models::Model).to receive(:SomeDate)
      allow_any_instance_of(Booker::Models::Model).to receive('Location')
      allow_any_instance_of(Booker::Models::Model).to receive('Locations')
      expect_any_instance_of(Booker::Models::Model).to receive(:x=).with('y')
      expect_any_instance_of(Booker::Models::Model).to receive(:SomeDate=).with(Time.zone.parse('1982-01-21 00:00:00 +0000'))
      expect_any_instance_of(Booker::Models::Model).to receive('Location=').with(a_kind_of Booker::Models::Location)
      expect_any_instance_of(Booker::Models::Model).to receive('Locations=').with(a_kind_of Array)
      allow_any_instance_of(Booker::Models::Model).to receive('Address')
      allow_any_instance_of(Booker::Models::Model).to receive('Addresses')
      allow_any_instance_of(Booker::Models::Model).to receive('Addresses=').with([123,456])
    end

    it 'creates a model from the hash' do
      expect(model).to be_a Booker::Models::Model
    end
  end

  describe '.from_list' do
    let(:models) {
      Booker::Models::Model.from_list([
          {x: 'y'},
          {a: 'b'}
        ])
    }

    it 'returns a list of models' do
      expect(Booker::Models::Model).to receive(:from_hash).twice.with(kind_of(Hash)).and_return(Booker::Models::Model.new)
      expect(models).to be_a(Array)
      expect(models[0]).to be_a Booker::Models::Model
    end
  end

  describe '.time_from_booker_datetime' do
    it 'converts the Booker datetime format to a time object in the current timzone AS IF it was eastern time' do
      expect(Booker::Models::Model.time_from_booker_datetime('/Date(380437200000-0500)/')).to eq Time.zone.parse('1982-01-21 00:00:00 -00:00')
    end
  end

  describe '.time_to_booker_datetime' do
    it 'converts the time to a Booker datetime string' do
      expect(Booker::Models::Model.time_to_booker_datetime(Time.parse('1982-01-21 00:00:00 +0000'))).to eq '/Date(380437200000)/'
      expect(Booker::Models::Model.time_to_booker_datetime(Time.parse('1982-01-21 00:00:00 +1200'))).to eq '/Date(380437200000)/'
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
