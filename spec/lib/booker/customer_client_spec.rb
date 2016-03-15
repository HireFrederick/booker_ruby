require 'spec_helper'

describe Booker::CustomerClient do
  let(:base_url) { 'https://apicurrent-app.booker.ninja/webservice4/json/CustomerService.svc' }
  let(:temp_access_token) { 'token' }
  let(:temp_access_token_expires_at) { Time.now + 1.minute }
  let(:client_id) { 'client_id' }
  let(:client_secret) { 'client_secret' }
  let(:client) do
    Booker::CustomerClient.new(
        temp_access_token: temp_access_token,
        temp_access_token_expires_at: temp_access_token_expires_at,
        client_id: client_id,
        client_secret: client_secret
    )
  end
  let(:token_store) { Booker::GenericTokenStore }
  let(:token_store_callback_method) { :update_booker_access_token! }

  it { is_expected.to be_a Booker::Client}

  describe 'modules' do
    it 'has right modules included' do
      expect(described_class.ancestors).to include Booker::CustomerREST
    end
  end

  describe '#initialize' do
    let(:base_url_override) { 'base_url' }
    let(:token_store_override) { 'string' }
    let(:token_store_callback_method_override) { 'token_store_callback_method' }
    let(:client) do
      Booker::CustomerClient.new(
          base_url: base_url_override,
          token_store: token_store_override,
          token_store_callback_method: token_store_callback_method_override
      )
    end

    it 'sets the default values' do
      expect(subject.base_url).to eq base_url
      expect(subject.token_store).to eq token_store
      expect(subject.token_store_callback_method).to be token_store_callback_method
    end

    it 'allows defaults to be overridden' do
      expect(client.base_url).to eq base_url_override
      expect(client.token_store).to eq token_store_override
      expect(client.token_store_callback_method).to eq token_store_callback_method_override
    end

    context "ENV['BOOKER_CUSTOMER_SERVICE_URL'] is set" do
      before do
        expect(ENV).to receive(:[]).with('BOOKER_CLIENT_ID')
        expect(ENV).to receive(:[]).with('BOOKER_CLIENT_SECRET')
        expect(ENV).to receive(:[]).with('BOOKER_CUSTOMER_SERVICE_URL').and_return 'http://from_env'
      end

      it 'sets the default value from env' do
        expect(subject.base_url).to eq 'http://from_env'
      end
    end
  end
  
  describe '#env_base_url_key' do
    it('returns env_base_url_key') { expect(subject.env_base_url_key).to eq 'BOOKER_CUSTOMER_SERVICE_URL' }
  end

  describe '#default_base_url' do
    it('returns default_base_url') do
      expect(subject.default_base_url).to eq base_url
    end
  end

  describe '#access_token_options' do
    it('returns access_token_options') do
      expect(client.access_token_options).to eq(
        client_id: client_id,
        client_secret: client_secret,
        grant_type: 'client_credentials'
      )
    end
  end

  describe 'super #get_access_token' do
    let(:temp_access_token) { nil }
    let(:temp_access_token_expires_at) { nil }
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

    before { allow(Time).to receive(:now).with(no_args).and_return(now) }

    context 'response present' do
      before do
        expect(client).to receive(:get).with('/access_token', http_options, nil).and_return(true)
        expect(true).to receive(:parsed_response).with(no_args).and_return(response)
        expect(client).to receive(:update_token_store).with(no_args)
      end

      it 'sets token info and returns a temp access token' do
        expect(token = client.get_access_token).to eq access_token
        expect(token).to eq client.temp_access_token
        expect(client.temp_access_token_expires_at).to be_a Time
        expect(client.temp_access_token_expires_at).to eq expires_at
      end
    end

    context 'response not present' do
      let(:response) { {} }

      before do
        expect(client).to receive(:get).with('/access_token', http_options, nil).and_raise(Booker::Error)
        expect(client).to_not receive(:update_token_store)
      end

      it 'raises Booker::InvalidApiCredentials, does not set token info' do
        expect { client.get_access_token }.to raise_error Booker::InvalidApiCredentials
        expect(client.temp_access_token_expires_at).to eq nil
        expect(client.temp_access_token).to eq nil
      end
    end
  end
end
