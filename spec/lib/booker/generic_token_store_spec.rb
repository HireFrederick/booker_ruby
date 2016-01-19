require 'spec_helper'

describe Booker::GenericTokenStore do
  after do
    described_class.temp_access_token = nil
    described_class.temp_access_token_expires_at = nil
  end

  describe '.temp_access_token=' do
    it 'sets a class instance variable' do
      expect(described_class.temp_access_token='foo').to eq 'foo'
      expect(described_class.instance_variable_get(:@temp_access_token)).to eq 'foo'
    end
  end

  describe '.temp_access_token' do
    before { described_class.instance_variable_set(:@temp_access_token, 'foo') }

    it 'gets a class instance variable' do
      expect(described_class.temp_access_token).to eq 'foo'
    end
  end

  describe '.temp_access_token_expires_at=' do
    it 'sets a class instance variable' do
      expect(described_class.temp_access_token_expires_at='foo').to eq 'foo'
      expect(described_class.instance_variable_get(:@temp_access_token_expires_at)).to eq 'foo'
    end
  end

  describe '.temp_access_token_expires_at' do
    before { described_class.instance_variable_set(:@temp_access_token_expires_at, 'foo') }

    it 'gets a class instance variable' do
      expect(described_class.temp_access_token_expires_at).to eq 'foo'
    end
  end

  describe '.update_booker_access_token!' do
    it 'updates the token and expires_at' do
      expect(described_class.update_booker_access_token!('foo', 'bar')).to be true
      expect(described_class.instance_variable_get(:@temp_access_token)).to eq 'foo'
      expect(described_class.instance_variable_get(:@temp_access_token_expires_at)).to eq 'bar'
    end
  end
end
