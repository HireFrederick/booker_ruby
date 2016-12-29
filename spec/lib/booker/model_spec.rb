require 'spec_helper'

describe Booker::Model do
  describe '#initialize' do
    let(:model) { described_class.new(:x => 'y', :a => 'b') }

    it 'calls .send for each key-value specified and stores the attribute keys' do
      expect_any_instance_of(described_class).to receive(:x=).with('y')
      expect_any_instance_of(described_class).to receive(:a=).with('b')
      expect(model.instance_variable_get(:@attributes)).to eq [:x, :a]
    end
  end

  describe '#to_json' do
    let(:model) { described_class.new }

    before do
      model.instance_variable_set(:@attributes, [:x])
      allow(model).to receive(:x).and_return 'y'
    end

    it 'returns a json hash of all attributes' do
      expect(JSON.parse(model.to_json)['x']).to eq 'y'
    end
  end

  describe '#to_hash' do
    let(:model) { described_class.new }
    let(:time) { Time.now }
    let(:date) { Date.today }
    let(:result) { model.to_hash }

    before do
      model.instance_variable_set :@attributes, [:x, :time, :date]
      allow(model).to receive(:x).and_return 'y'
      allow(model).to receive(:time).and_return time
      allow(model).to receive(:date).and_return date
    end

    it 'returns a hash of all attributes' do
      expect(result[:x]).to eq 'y'
      expect(result[:time]).to be time
      expect(result[:date]).to be date
    end
  end

  describe '.from_hash' do
    let(:model) {
      described_class.from_hash({
        x: 'y',
        SomeDate: '/Date(380437200000-0500)/',
        'Location' => {
          a: 'b'
        },
        locations: [{
          c: 'd'
        }],
        classInstances: [{
          e: 'f'
        }],
        Addresses: [123,456],
        Address: nil
      })
    }

    before do
      allow_any_instance_of(described_class).to receive(:respond_to?).and_return true
      expect(described_class).to receive(:constantize).with('Location').and_return Booker::V4::Models::Location
      expect(described_class).to receive(:constantize).with(:locations).and_return Booker::V4::Models::Location
      expect(described_class).to receive(:constantize).with(:Address).and_return Booker::V4::Models::Address
      expect(described_class).to receive(:constantize).with(:Addresses).and_return Booker::V4::Models::Address
      expect(described_class).to receive(:constantize).with(:classInstances).and_return Booker::V4::Models::ClassInstance
      expect(described_class).to receive(:constantize).with(:x)
      expect(described_class).to receive(:constantize).with(:a)
      expect(described_class).to receive(:constantize).with(:c)
      expect(described_class).to receive(:constantize).with(:e)
      expect(described_class).to receive(:constantize).with(:SomeDate)

      allow_any_instance_of(described_class).to receive(:x)
      allow_any_instance_of(described_class).to receive(:SomeDate)
      allow_any_instance_of(described_class).to receive('Location')
      allow_any_instance_of(described_class).to receive('locations')
      allow_any_instance_of(described_class).to receive('classInstances')
      expect_any_instance_of(described_class).to receive(:x=).with('y')
      expect_any_instance_of(described_class).to receive(:SomeDate=).with('/Date(380437200000-0500)/')
      expect_any_instance_of(described_class).to receive('Location=').with(a_kind_of Booker::V4::Models::Location)
      expect_any_instance_of(described_class).to receive('a=')
      expect_any_instance_of(described_class).to receive('c=')
      expect_any_instance_of(described_class).to receive('e=')
      expect_any_instance_of(described_class).to receive('locations=').with(array_including(kind_of(Booker::V4::Models::Location)))
      expect_any_instance_of(described_class).to receive('classInstances=').with(array_including(kind_of(Booker::V4::Models::ClassInstance)))
      allow_any_instance_of(described_class).to receive('Address')
      allow_any_instance_of(described_class).to receive('Address=')
      allow_any_instance_of(described_class).to receive('Addresses')
      allow_any_instance_of(described_class).to receive('Addresses=').with([123,456])
    end

    it 'creates a model from the hash' do
      expect(model).to be_a described_class
    end
  end

  describe '.from_list' do
    let(:models) {
      described_class.from_list([
        {x: 'y'},
        {a: 'b'}
      ])
    }

    it 'returns a list of models' do
      expect(described_class).to receive(:from_hash).twice.with(kind_of(Hash)).and_return(described_class.new)
      expect(models).to be_a(Array)
      expect(models[0]).to be_a described_class
    end
  end
end
