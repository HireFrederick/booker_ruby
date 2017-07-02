require 'spec_helper'

describe Booker::V4::BusinessClient do
  describe 'constants' do
    it 'sets constants to right vals' do
      expect(described_class::ENV_BASE_URL_KEY).to eq 'BOOKER_BUSINESS_SERVICE_URL'
      expect(described_class::DEFAULT_BASE_URL).to eq 'https://apicurrent-app.booker.ninja/webservice4/json/BusinessService.svc'
    end
  end

  describe 'modules' do
    it 'has right modules included' do
      expect(described_class.ancestors).to include Booker::V4::BusinessREST
    end
  end

  describe '#get_base_url' do
    it 'returns default_base_url' do
      expect(subject.get_base_url).to eq described_class::DEFAULT_BASE_URL
    end

    context 'from env' do
      before { ENV['BOOKER_BUSINESS_SERVICE_URL'] = 'http://from_env' }
      after { ENV['BOOKER_BUSINESS_SERVICE_URL'] = nil }

      it 'returns from env' do
        expect(subject.get_base_url).to eq 'http://from_env'
      end
    end
  end
end
