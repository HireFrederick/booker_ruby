require 'spec_helper'

describe Booker::Models::Model do
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
end
