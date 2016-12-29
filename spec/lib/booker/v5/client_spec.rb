require 'spec_helper'

describe Booker::V5::Client do
  let(:base_url) { 'https://api-staging.booker.com' }
  let(:temp_access_token) { 'token' }
  let(:temp_access_token_expires_at) { Time.now + 1.minute }
  let(:client_id) { 'client_id' }
  let(:client_secret) { 'client_secret' }
  let(:api_subscription_key) { 'sub_key' }
  let(:access_token_scope) { 'merchant' }
  let(:location_id) { nil }
  let(:client) do
    Booker::V5::Client.new(
      temp_access_token: temp_access_token,
      temp_access_token_expires_at: temp_access_token_expires_at,
      client_id: client_id,
      client_secret: client_secret,
      api_subscription_key: api_subscription_key,
      access_token_scope: access_token_scope,
      location_id: location_id
    )
  end

  it { is_expected.to be_a(Booker::Client) }

  describe 'constants' do
    it 'sets constants to right vals' do
      expect(described_class::CREATE_TOKEN_CONTENT_TYPE).to eq 'application/x-www-form-urlencoded'
      expect(described_class::CREATE_TOKEN_GRANT_TYPE).to eq 'client_credentials'
      expect(described_class::CREATE_TOKEN_PATH).to eq '/v5/auth/connect/token'
      expect(described_class::ENV_BASE_URL_KEY).to eq 'BOOKER_API_BASE_URL'
      expect(described_class::DEFAULT_BASE_URL).to eq 'https://api-staging.booker.com'
      expect(described_class::VALID_ACCESS_TOKEN_SCOPES).to eq %w(public merchant parter-payment internal)
      expect(described_class::API_GATEWAY_ERRORS).to eq({
        503 => Booker::ServiceUnavailable,
        504 => Booker::ServiceUnavailable,
        429 => Booker::RateLimitExceeded,
        401 => Booker::InvalidApiCredentials,
        403 => Booker::InvalidApiCredentials
      })
    end
  end

  describe '#initialize' do
    it 'builds a client with the valid options given' do
      expect(client.temp_access_token).to eq 'token'
      expect(client.temp_access_token_expires_at).to be_a(Time)
    end

    it 'uses the default base url when none is provided' do
      expect(client.base_url).to eq 'https://api-staging.booker.com'
    end

    describe 'default access token scope' do
      let(:access_token_scope) { nil }

      it 'is public when no location id' do
        expect(client.access_token_scope).to eq 'public'
      end

      context 'location id' do
        let(:location_id) { 456 }

        it 'is merchant' do
          expect(client.access_token_scope).to eq 'merchant'
        end
      end
    end

    context "ENV['BOOKER_API_GATEWAY_BASE_URL'] is set, not passed in" do
      before do
        expect(ENV).to receive(:[]).with('BOOKER_API_BASE_URL').and_return 'http://from_env'
      end

      it 'sets the default value from env' do
        expect(client.base_url).to eq 'http://from_env'
      end
    end

    context "ENV['BOOKER_API_SUBSCRIPTION_KEY' is set, not passed in" do
      let(:api_subscription_key) { nil }

      before do
        expect(ENV).to receive(:[]).with('BOOKER_API_BASE_URL')
        expect(ENV).to receive(:[]).with('BOOKER_API_SUBSCRIPTION_KEY').and_return 'fooBar'
      end

      it 'sets the default value from env' do
        expect(client.api_subscription_key).to eq 'fooBar'
      end
    end

    context 'invalid access token scope' do
      let(:access_token_scope) { 'overlord' }

      it 'raises error' do
        expect{client}.to raise_error(
          ArgumentError, "access_token_scope must be one of: #{described_class::VALID_ACCESS_TOKEN_SCOPES.join(', ')}"
        )
      end
    end
  end

  describe '#env_base_url_key' do
    it('returns env_base_url_key') { expect(subject.env_base_url_key).to eq 'BOOKER_API_BASE_URL' }
  end

  describe '#default_base_url' do
    it('returns default_base_url') do
      expect(subject.default_base_url).to eq base_url
    end
  end

  describe '#get_access_token' do
    let(:temp_access_token) { nil }
    let(:temp_access_token_expires_at) { nil }
    let(:now) { Time.parse('2015-01-09') }
    let(:expires_in) { 100 }
    let(:expires_at) { now + expires_in }
    let(:access_token) { 'access_token' }
    let(:response) { instance_double(HTTParty::Response, parsed_response: parsed_response) }
    let(:parsed_response) do
      {
        'expires_in' => expires_in.to_s,
        'access_token' => access_token

      }
    end
    let(:result) { client.get_access_token }

    before do
      allow(Time).to receive(:now).with(no_args).and_return(now)
      expect(client).to receive(:access_token_response).and_return(response)
      expect(client).to receive(:update_token_store).with(no_args)
    end

    it 'sets token info and returns a temp access token' do
      expect(result).to eq access_token
      expect(result).to eq client.temp_access_token
      expect(client.temp_access_token_expires_at).to be_a Time
      expect(client.temp_access_token_expires_at).to eq expires_at
    end

    context 'client has location_id' do
      let(:location_token) { 'location token' }
      let(:location_id) { 31415926 }

      before { expect(client).to receive(:get_location_access_token).and_return location_token }

      it 'gets a location access token and returns it as temp access token' do
        expect(result).to eq location_token
        expect(result).to eq client.temp_access_token
        expect(client.temp_access_token_expires_at).to be_a Time
        expect(client.temp_access_token_expires_at).to eq expires_at
      end
    end
  end

  describe '#access_token_response' do
    let(:url) { "#{base_url}/v5/auth/connect/token"  }
    let(:options) do
      {
        headers: {
          'Content-Type': described_class::CREATE_TOKEN_CONTENT_TYPE,
          'Ocp-Apim-Subscription-Key': api_subscription_key
        },
        body: {
          grant_type: described_class::CREATE_TOKEN_GRANT_TYPE,
          client_id: client_id,
          client_secret: client_secret,
          scope: access_token_scope
        }.to_query
      }
    end
    let(:resp) { instance_double(HTTParty::Response, success?: true, code: 201, parsed_response: {}) }

    before { expect(HTTParty).to receive(:post).with(url, options).and_return resp }

    context 'success' do
      it 'returns response' do
        expect(client.access_token_response).to eq resp
      end
    end

    context 'non-recoverable error' do
      let(:resp) { instance_double(HTTParty::Response, success?: true, code: 401, parsed_response: {}) }

      it 'retries once' do
        expect{client.access_token_response}.to raise_error(Booker::InvalidApiCredentials)
      end
    end

    context 'recoverable errors' do
      before do
        expect(HTTParty).to receive(:post).with(url, options).and_return resp2
        expect(client).to receive(:sleep).with(1)
      end

      context 'Booker::ServiceUnavailable error' do
        let(:resp) { instance_double(HTTParty::Response, success?: true, code: 503, parsed_response: {}) }
        let(:resp2) { instance_double(HTTParty::Response, success?: true, code: 503, parsed_response: {}) }

        it 'retries once' do
          expect{client.access_token_response}.to raise_error(Booker::ServiceUnavailable)
        end

        context 'success on second retry' do
          let(:resp2) { instance_double(HTTParty::Response, success?: true, code: 200, parsed_response: {}) }

          it 'returns response' do
            expect(client.access_token_response).to eq resp2
          end
        end
      end

      context 'Booker::RateLimitExceeded error' do
        let(:resp) { instance_double(HTTParty::Response, success?: true, code: 429, parsed_response: {}) }
        let(:resp2) { instance_double(HTTParty::Response, success?: true, code: 429, parsed_response: {}) }

        it 'retries once' do
          expect{client.access_token_response}.to raise_error(Booker::RateLimitExceeded)
        end

        context 'success on second retry' do
          let(:resp2) { instance_double(HTTParty::Response, success?: true, code: 200, parsed_response: {}) }

          it 'returns response' do
            expect(client.access_token_response).to eq resp2
          end
        end
      end
    end
  end

  describe '#get_location_access_token' do
    let(:url) { "#{base_url}/v5/auth/context/update"  }
    let(:location_id) { 123 }
    let(:original_token) { 'token' }
    let(:options) do
      {
        headers: {
          'Ocp-Apim-Subscription-Key': api_subscription_key,
          Authorization: "Bearer #{original_token}"
        },
        query: {
          locationId: location_id
        }
      }
    end
    let(:new_token) { 'new token' }
    let(:resp) { instance_double(HTTParty::Response, success?: true, code: 200, parsed_response: new_token) }
    let(:result) { client.get_location_access_token(original_token, location_id) }

    before { expect(HTTParty).to receive(:post).with(url, options).and_return resp }

    context 'success' do
      it 'returns response' do
        expect(result).to eq new_token
      end
    end

    context 'non-recoverable error' do
      let(:resp) { instance_double(HTTParty::Response, success?: true, code: 401, parsed_response: {}) }

      it 'retries once' do
        expect{result}.to raise_error(Booker::InvalidApiCredentials)
      end
    end

    context 'recoverable errors' do
      before do
        expect(HTTParty).to receive(:post).with(url, options).and_return resp2
        expect(client).to receive(:sleep).with(1)
      end

      context 'Booker::ServiceUnavailable error' do
        let(:resp) { instance_double(HTTParty::Response, success?: true, code: 503, parsed_response: {}) }
        let(:resp2) { instance_double(HTTParty::Response, success?: true, code: 503, parsed_response: {}) }

        it 'retries once' do
          expect{result}.to raise_error(Booker::ServiceUnavailable)
        end

        context 'success on second retry' do
          let(:resp2) { instance_double(HTTParty::Response, success?: true, code: 200, parsed_response: new_token) }

          it 'returns response' do
            expect(result).to eq new_token
          end
        end
      end

      context 'Booker::RateLimitExceeded error' do
        let(:resp) { instance_double(HTTParty::Response, success?: true, code: 429, parsed_response: {}) }
        let(:resp2) { instance_double(HTTParty::Response, success?: true, code: 429, parsed_response: {}) }

        it 'retries once' do
          expect{result}.to raise_error(Booker::RateLimitExceeded)
        end

        context 'success on second retry' do
          let(:resp2) { instance_double(HTTParty::Response, success?: true, code: 200, parsed_response: new_token) }

          it 'returns response' do
            expect(result).to eq new_token
          end
        end
      end
    end
  end

  describe 'super #handle_errors' do
    let(:request) { 'request' }
    let(:url) { 'url' }

    it 'raises API Gateway errors' do
      described_class::API_GATEWAY_ERRORS.each do |k, v|
        response = instance_double(HTTParty::Response, code: k, parsed_response: {})
        expect{client.send(:handle_errors!, url, request, response)}.to raise_error v
      end
    end

    it 'super' do
      response = instance_double(HTTParty::Response, success?: false, code: 422, parsed_response: {})
      expect{client.send(:handle_errors!, url, request, response)}.to raise_error Booker::Error
    end
  end

  describe 'super #request_options' do
    it 'adds Authorization header to super' do
      expect(client.send(:request_options)[:headers][:Authorization]).to eq "Bearer #{client.access_token}"
    end
  end
end
