require 'spec_helper'

describe Booker::BusinessClient do
  let(:temp_access_token) { 'token' }
  let(:temp_access_token_expires_at) { Time.now + 1.minute }
  let(:client_id) { 'client_id' }
  let(:client_secret) { 'client_secret' }
  let(:booker_account_name) { 'booker_account_name' }
  let(:booker_username) { 'booker_username' }
  let(:booker_password) { 'booker_password' }
  let(:client) do
    Booker::BusinessClient.new(
        temp_access_token: temp_access_token,
        temp_access_token_expires_at: temp_access_token_expires_at,
        client_id: client_id,
        client_secret: client_secret,
        booker_account_name: booker_account_name,
        booker_username: booker_username,
        booker_password: booker_password
    )
  end

  describe '#initialize' do
    it 'builds a client with the valid options given' do
      expect(client.temp_access_token).to eq 'token'
      expect(client.temp_access_token_expires_at).to be_a(Time)
    end

    it 'uses the default base url when none is provided' do
      expect(client.base_url).to eq 'https://apicurrent-app.booker.ninja/webservice4/json/BusinessService.svc'
    end

    context "ENV['BOOKER_BUSINESS_SERVICE_URL'] is set" do
      before { expect(ENV).to receive(:[]).with('BOOKER_BUSINESS_SERVICE_URL').and_return 'http://from_env' }

      it 'sets the default value from env' do
        expect(subject.base_url).to eq 'http://from_env'
      end
    end
  end

  describe '#get_access_token' do
    let(:temp_access_token) { nil }
    let(:temp_access_token_expires_at) { nil }
    let(:http_options) do
      {
          client_id: client_id,
          client_secret: client_secret,
          'AccountName' => booker_account_name,
          'UserName' => booker_username,
          'Password' => booker_password
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
      expect(client).to receive(:post).with('/accountlogin', http_options, nil).and_return(true)
      expect(true).to receive(:parsed_response).with(no_args).and_return(response)
    end

    context 'response present' do
      before { expect(client).to receive(:update_token_store).with(no_args) }

      it 'sets token info and returns a temp access token' do
        token = client.get_access_token
        expect(token).to eq access_token
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
