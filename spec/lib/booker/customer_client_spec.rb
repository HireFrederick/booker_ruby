require 'spec_helper'

describe Booker::CustomerClient do
  let(:client_id) { 'client_id' }
  let(:client_secret) { 'client_secret' }
  let(:client) do
    Booker::CustomerClient.new(
        client_id: client_id,
        client_secret: client_secret
    )
  end

  it { is_expected.to be_a Booker::Client}

  describe '#initialize' do
    it 'sets the default values' do
      expect(subject.base_url).to eq 'https://apicurrent-app.booker.ninja/webservice4/json/CustomerService.svc'
      expect(subject.token_store).to be Booker::GenericTokenStore
      expect(subject.token_store_callback_method).to be :update_booker_access_token!
    end

    it 'allows defaults to be overridden' do
      client = Booker::CustomerClient.new(base_url: 'http://foo')
      expect(client.base_url).to eq 'http://foo'
    end

    context "ENV['BOOKER_CUSTOMER_SERVICE_URL'] is set" do
      before { expect(ENV).to receive(:[]).with('BOOKER_CUSTOMER_SERVICE_URL').and_return 'http://from_env' }

      it 'sets the default value from env' do
        expect(subject.base_url).to eq 'http://from_env'
      end
    end
  end

  describe '#get_access_token' do
    let(:http_options) do
      {
          client_id: client_id,
          client_secret: client_secret,
          grant_type: 'client_credentials'
      }
    end
    let(:now) { Time.parse('2015-01-09') }
    let(:expires_in) { 100 }
    let(:expires_at) { now + expires_in }
    let(:access_token) { 'access_token' }
    let(:response) do
      {
          'expires_in' => expires_in.to_s,
          'access_token' => access_token

      }
    end

    before do
      allow(Time).to receive(:now).with(no_args).and_return(now)
      expect(client).to receive(:get).with('/access_token', http_options, nil).and_return(true)
      expect(true).to receive(:parsed_response).with(no_args).and_return(response)
    end

    context 'response present' do
      before { expect(client).to receive(:update_token_store).with(no_args) }

      it 'sets token info and returns a temp access token' do
        expect(token = client.get_access_token).to eq access_token
        expect(token).to eq client.temp_access_token
        expect(client.temp_access_token_expires_at).to be_a Time
        expect(client.temp_access_token_expires_at).to eq expires_at
      end
    end

    context 'response not present' do
      let(:response) { {} }

      before { expect(client).to_not receive(:update_token_store) }

      it 'raises Booker::InvalidApiCredentials, does not set token info' do
        expect { client.get_access_token }.to raise_error Booker::InvalidApiCredentials
        expect(client.temp_access_token_expires_at).to eq nil
        expect(client.temp_access_token).to eq nil
      end
    end
  end
end
