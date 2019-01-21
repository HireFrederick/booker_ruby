require 'spec_helper'

describe Booker::Client do
  let(:base_url) { described_class::DEFAULT_BASE_URL }
  let(:client_id) { 'client_id' }
  let(:client_secret) { 'client_secret' }
  let(:temp_access_token) { 'temp_access_token' }
  let(:temp_access_token_expires_at) { Time.now + 1.minute }
  let(:refresh_token) { 'refresh_token' }
  let(:api_subscription_key) { 'sub_key' }
  let(:access_token_scope) { 'merchant' }
  let(:location_id) { nil }
  let(:auth_with_client_credentials) { false }
  let(:client) do
    Booker::Client.new(
      base_url: base_url,
      temp_access_token: temp_access_token,
      client_id: client_id,
      client_secret: client_secret,
      token_store: token_store,
      token_store_callback_method: token_store_callback_method,
      api_subscription_key: api_subscription_key,
      location_id: location_id,
      auth_with_client_credentials: auth_with_client_credentials,
      refresh_token: refresh_token
    )
  end
  let(:token_store) { Booker::GenericTokenStore }
  let(:token_store_callback_method) { :update_booker_access_token! }
  let(:http_options) do
    {
        client_id: client_id,
        client_secret: client_secret,
    }
  end
  let(:response) { 'response' }
  let!(:jwt_stubs) do
    allow_any_instance_of(described_class).to receive(:token_expires_at).and_return temp_access_token_expires_at
    allow_any_instance_of(described_class).to receive(:token_scope).and_return access_token_scope
  end

  describe 'constants' do
    it 'sets constants to right vals' do
      expect(described_class::CREATE_TOKEN_CONTENT_TYPE).to eq 'application/x-www-form-urlencoded'
      expect(described_class::CLIENT_CREDENTIALS_GRANT_TYPE).to eq 'client_credentials'
      expect(described_class::REFRESH_TOKEN_GRANT_TYPE).to eq 'refresh_token'
      expect(described_class::CREATE_TOKEN_PATH).to eq '/v5/auth/connect/token'
      expect(described_class::UPDATE_TOKEN_CONTEXT_PATH).to eq '/v5/auth/context/update'
      expect(described_class::VALID_ACCESS_TOKEN_SCOPES).to eq %w(public merchant parter-payment internal)
      expect(described_class::DEFAULT_BASE_URL).to eq 'https://api-staging.booker.com'
      expect(described_class::DEFAULT_AUTH_BASE_URL).to eq 'https://api-staging.booker.com'
      expect(described_class::API_GATEWAY_ERRORS).to eq({
        503 => Booker::ServiceUnavailable,
        504 => Booker::ServiceUnavailable,
        429 => Booker::RateLimitExceeded,
        401 => Booker::InvalidApiCredentials,
        403 => Booker::InvalidApiCredentials
      })
      expect(described_class::BOOKER_SERVER_TIMEZONE).to eq 'Eastern Time (US & Canada)'
    end
  end

  describe '.new' do
    let!(:jwt_stubs) do
      allow_any_instance_of(described_class).to receive(:token_expires_at)
                                                  .with(temp_access_token).and_return temp_access_token_expires_at
      allow_any_instance_of(described_class).to receive(:token_scope)
                                                  .with(temp_access_token).and_return access_token_scope
    end
    let(:env_base_url) { 'api base url from env' }

    before do
      allow(ENV).to receive(:[]).with('BOOKER_CLIENT_ID').and_return 'id from env'
      allow(ENV).to receive(:[]).with('BOOKER_CLIENT_SECRET').and_return 'secret from env'
      allow(ENV).to receive(:[]).with('BOOKER_API_BASE_URL').and_return env_base_url
      allow(ENV).to receive(:[]).with('BOOKER_API_SUBSCRIPTION_KEY').and_return 'sub key from env'
      allow(ENV).to receive(:[]).with('BOOKER_API_AUTH_WITH_CLIENT_CREDENTIALS').and_return 'true'
    end

    it 'builds a client with the valid options given' do
      expect(client.base_url).to eq base_url
      expect(client.temp_access_token).to eq temp_access_token
      expect(client.refresh_token).to eq refresh_token
      expect(client.temp_access_token_expires_at).to eq temp_access_token_expires_at
      expect(client.client_id).to eq client_id
      expect(client.client_secret).to eq client_secret
      expect(client.auth_with_client_credentials).to be false
      expect(client.access_token_scope).to eq access_token_scope
    end

    context 'token provided but has expired' do
      let(:error) { JWT::ExpiredSignature.new }
      let!(:jwt_stubs) do
        allow_any_instance_of(described_class).to receive(:token_expires_at).and_raise error
      end

      it 'rescues and does not set options from the token' do
        expect(client.temp_access_token).to eq temp_access_token
        expect(client.temp_access_token_expires_at).to be_nil
        expect(client.access_token_scope).to eq 'public'
      end

      context 'auth_with_client_credentials, no refresh_token' do
        let(:auth_with_client_credentials) { true }
        let(:refresh_token) { nil }

        it 'rescues and does not set options from the token' do
          expect(client.temp_access_token).to eq temp_access_token
          expect(client.temp_access_token_expires_at).to be_nil
          expect(client.access_token_scope).to eq 'public'
        end
      end

      context 'neither refresh_token nor auth_with_client_credentials' do
        let(:refresh_token) { nil }

        it 'raises' do
          expect{client}.to raise_error error
        end
      end
    end

    context 'no BOOKER_API_BASE_URL in ENV' do
      let(:env_base_url) { nil }

      it 'sets default auth base url' do
        expect(client.auth_base_url).to eq described_class::DEFAULT_AUTH_BASE_URL
      end
    end

    context 'no access token or scope provided' do
      let(:client) { Booker::Client.new }

      it 'sets default access token scope to public' do
        expect(client.access_token_scope).to eq 'public'
      end
    end

    context 'defaults from ENV' do
      let(:client) { Booker::Client.new }

      it 'loads from ENV' do
        expect(client.client_id).to eq 'id from env'
        expect(client.client_secret).to eq 'secret from env'
        expect(client.auth_with_client_credentials).to be true
        expect(client.auth_base_url).to eq 'api base url from env'
        expect(client.api_subscription_key).to eq 'sub key from env'
      end
    end
  end

  describe '#get_base_url' do
    it 'returns default_base_url' do
      expect(subject.get_base_url).to eq described_class::DEFAULT_BASE_URL
    end

    context 'from env' do
      before { ENV['BOOKER_API_BASE_URL'] = 'http://from_env' }
      after { ENV['BOOKER_API_BASE_URL'] = nil }

      it 'returns from env' do
        expect(subject.get_base_url).to eq 'http://from_env'
      end
    end
  end

  describe '#get' do
    let(:http_party_options) {
      {
          headers: {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
            'Authorization' => "Bearer #{temp_access_token}",
            'Ocp-Apim-Subscription-Key' => api_subscription_key
          },
          query: data,
          timeout: 30,
      }
    }
    let(:data) { {data: 'datum'} }
    let(:resp) { instance_double(HTTParty::Response, parsed_response: {'Results' => [data]}, code: 200) }

    it 'makes the request using the options given' do
      expect(client).to receive(:get_booker_resources).with(:get, '/blah/blah', data, nil, Booker::V4::Models::Model).and_call_original
      expect(HTTParty).to receive(:get).with("#{client.base_url}/blah/blah", http_party_options).and_return(resp)
      expect(resp).to receive(:success?).and_return(true)
      expect(Booker::V4::Models::Model).to receive(:from_list).with([data]).and_return(['results'])
      expect(client.get('/blah/blah', data, Booker::V4::Models::Model)).to eq ['results']
    end

    it 'allows you to not pass in a booker model' do
      expect(HTTParty).to receive(:get).with("#{client.base_url}/blah/blah", http_party_options).and_return(resp)
      expect(resp).to receive(:success?).and_return(true)
      expect(client.get('/blah/blah', data)).to eq [data]
    end
  end

  describe '#post' do
    let(:http_party_options) {
      {
        headers: {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{temp_access_token}",
          'Accept' => 'application/json',
          'Ocp-Apim-Subscription-Key' => api_subscription_key
        },
          body: post_data.to_json,
          timeout: 30,
      }
    }
    let(:data) { {data: 'datum'} }
    let(:resp) { instance_double(HTTParty::Response, parsed_response: {'Results' => [data]}, code: 200) }
    let(:post_data) { {"lUserID" => 13240029,"lBusinessID" => "25142"} }

    it 'makes the request using the options given' do
      expect(client).to receive(:get_booker_resources).with(:post, '/blah/blah', nil, post_data.to_json, Booker::V4::Models::Model).and_call_original
      expect(HTTParty).to receive(:post).with("#{client.base_url}/blah/blah", http_party_options).and_return(resp)
      expect(resp).to receive(:success?).and_return(true)
      expect(Booker::V4::Models::Model).to receive(:from_list).with([data]).and_return(['results'])
      expect(client.post('/blah/blah', post_data, Booker::V4::Models::Model)).to eq ['results']
    end

    it 'allows you to not pass in a booker model' do
      expect(HTTParty).to receive(:post).with("#{client.base_url}blah/blah", http_party_options).and_return(resp)
      expect(resp).to receive(:success?).and_return(true)
      expect(client.post('blah/blah', post_data)).to eq [data]
    end
  end

  describe '#put' do
    let(:http_party_options) {
      {
        headers: {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'Authorization' => "Bearer #{temp_access_token}",
          'Ocp-Apim-Subscription-Key' => api_subscription_key
        },
        body: post_data.to_json,
        timeout: 30
      }
    }
    let(:data) { {data: 'datum'} }
    let(:resp) { instance_double(HTTParty::Response, parsed_response: {'Results' => [data]}, code: 200) }
    let(:post_data) { {"lUserID" => 13240029,"lBusinessID" => "25142"} }

    it 'makes the request using the options given' do
      expect(client).to receive(:get_booker_resources).with(:put, '/blah/blah', nil, post_data.to_json, Booker::V4::Models::Model).and_call_original
      expect(HTTParty).to receive(:put).with("#{client.base_url}/blah/blah", http_party_options).and_return(resp)
      expect(resp).to receive(:success?).and_return(true)
      expect(Booker::V4::Models::Model).to receive(:from_list).with([data]).and_return(['results'])
      expect(client.put('/blah/blah', post_data, Booker::V4::Models::Model)).to eq ['results']
    end

    it 'allows you to not pass in a booker model' do
      expect(HTTParty).to receive(:put).with("#{client.base_url}blah/blah", http_party_options).and_return(resp)
      expect(resp).to receive(:success?).and_return(true)
      expect(client.put('blah/blah', post_data)).to eq [data]
    end
  end

  describe '#delete' do
    let(:http_party_options) {
      {
        headers: {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'Authorization' => "Bearer #{temp_access_token}",
          'Ocp-Apim-Subscription-Key' => api_subscription_key
        },
        query: params,
        body: post_data.to_json,
        timeout: 30
      }
    }
    let(:data) { {data: 'datum'} }
    let(:params) { {foo: 'bar'} }
    let(:resp) { instance_double(HTTParty::Response, parsed_response: {'Results' => [data]}, code: 200) }
    let(:post_data) { {"lUserID" => 13240029,"lBusinessID" => "25142"} }

    it 'makes the request using the options given' do
      expect(client).to receive(:get_booker_resources).with(:delete, '/blah/blah', params, post_data.to_json, Booker::V4::Models::Model).and_call_original
      expect(HTTParty).to receive(:delete).with("#{client.base_url}/blah/blah", http_party_options).and_return(resp)
      expect(resp).to receive(:success?).and_return(true)
      expect(Booker::V4::Models::Model).to receive(:from_list).with([data]).and_return(['results'])
      expect(client.delete('/blah/blah', params, post_data, Booker::V4::Models::Model)).to eq ['results']
    end
  end

  describe '#paginated_request' do
    let(:path) { '/appointments' }

    context 'valid params' do
      let(:params_1) do
        {
          UsePaging: true,
          PageSize: 3,
          PageNumber: 1
        }
      end
      let(:results) { [result_1, result_2, result_3] }
      let(:result_1) { Booker::V4::Models::Customer.new(LocationID: 123, FirstName: 'Jim') }
      let(:result_2) { Booker::V4::Models::Customer.new(LocationID: 456) }
      let(:result_3) { Booker::V4::Models::Customer.new(LocationID: 123, FirstName: 'Jim') }
      let(:base_paginated_request_args) { {method: 'method', path: path, params: params_1, model: Booker::V4::Models::Model} }
      let(:paginated_request_args) { base_paginated_request_args }

      before { expect(client).to receive(:send).with('method', path, params_1, Booker::V4::Models::Model).and_return(results) }

      context 'fetch all is true' do
        let(:params_2) { params_1.merge(PageNumber: (params_1[:PageNumber] + 1)) }
        let(:params_3) { params_1.merge(PageNumber: (params_1[:PageNumber] + 2)) }
        let(:result_4) { Booker::V4::Models::Customer.new(LocationID: 123, FirstName: 'Jim') }
        let(:result_5) { Booker::V4::Models::Customer.new(LocationID: 123, FirstName: 'John') }
        let(:total_missing) { params_2[:PageSize] - results2.length }
        let(:raven_msg) { "Page of #{path} has less records then specified in page size. Ensure this is not last page of request" }
        let(:results2) { [result_4, result_5] }
        let(:results3) { [] }

        before do
          expect(client).to receive(:send).with('method', path, params_2, Booker::V4::Models::Model).and_return(results2)
          expect(client).to receive(:send).with('method', path, params_3, Booker::V4::Models::Model).and_return(results3)
        end

        it 'calls the request method for each page, returning the combined result set' do
          expect(client.paginated_request(paginated_request_args)).to eq [result_1, result_2, result_3, result_4, result_5]
        end
      end

      context 'fetch all is false' do
        let(:paginated_request_args) { base_paginated_request_args.merge(fetch_all: false) }

        it 'returns the first page of results' do
          expect(client.paginated_request(paginated_request_args)).to eq results
        end
      end
    end

    context 'invalid params' do
      let(:use_paging) { true }
      let(:page_size) { 2 }
      let(:page_number) { 1 }

      it 'invalid UsePaging' do
        [nil, false].each do |val|
          expect{client.paginated_request(method: 'method', path: path, params: {
            UsePaging: val,
            PageSize: page_size,
            PageNumber: page_number
            }, model: Booker::V4::Models::Model)}.to raise_error(ArgumentError, 'params must include valid PageSize, PageNumber and UsePaging')
        end
      end

      it 'invalid PageSize' do
        [nil, 0].each do |val|
          expect{client.paginated_request(method: 'method', path: path, params: {
            UsePaging: use_paging,
            PageSize: val,
            PageNumber: page_number
          }, model: Booker::V4::Models::Model)}.to raise_error(ArgumentError, 'params must include valid PageSize, PageNumber and UsePaging')
        end
      end

      it 'invalid PageNumber' do
        [nil, 0].each do |val|
          expect{client.paginated_request(method: 'method', path: path, params: {
            UsePaging: use_paging,
            PageSize: page_size,
            PageNumber: val
            }, model: Booker::V4::Models::Model)}.to raise_error(ArgumentError, 'params must include valid PageSize, PageNumber and UsePaging')
        end
      end
    end

    context 'result is not a list' do
      let(:page_number) { 1 }
      let(:params) do
        {
          UsePaging: true,
          PageSize: 2,
          PageNumber: page_number
        }
      end
      let(:base_paginated_params) { {method: 'method', path: path, params: params, model: Booker::V4::Models::Model, fetch_all: true} }
      let(:pagination_params) { base_paginated_params }
      let(:result) { client.paginated_request(pagination_params) }

      context 'first page returns a non-array' do
        before do
          expect(client).to receive(:send).with('method', path, params, Booker::V4::Models::Model).and_return('foo')
          expect_any_instance_of(StandardError).to receive(:instance_variable_set).with(:@error_occurred_during_params, params)
          expect_any_instance_of(StandardError).to receive(:instance_variable_set).with(:@results_prior_to_error, [])
        end

        it 'raises error; returns hash of message, params, and results successfully fetched prior to error' do
          expect{result}.to raise_error(StandardError, "Result from paginated request to #{path} with params: #{params} is not a collection")
        end
      end
      context 'when fetched param is non-empty' do
        let(:order_data) { 'A+ results' }
        let(:already_fetched) { [order_data, order_data, order_data] }
        let(:error_page) { 'not an array' }
        let(:page_number) { 5 }
        let(:pagination_params) { base_paginated_params.merge({fetched: already_fetched}) }

        before do
          expect(client).to receive(:send).with('method', path, params, Booker::V4::Models::Model).and_return(error_page)
          expect_any_instance_of(StandardError).to receive(:instance_variable_set).with(:@error_occurred_during_params, params)
          expect_any_instance_of(StandardError).to receive(:instance_variable_set).with(:@results_prior_to_error, already_fetched)
        end

        it 'raises error; returns results prior to error' do
          expect{result}.to raise_error(StandardError, "Result from paginated request to #{path} with params: {:UsePaging=>true, :PageSize=>2, :PageNumber=>5} is not a collection")
        end
      end
    end
  end

  describe '#get_booker_resources' do
    let(:data) { {data: 'datum'} }
    let(:resp) { instance_double(HTTParty::Response, parsed_response: parsed_response, code: 200) }
    let(:parsed_response) { {'Results' => [data]} }
    let(:params) { {foo: 'bar'} }
    let(:body) { {bar: 'foo'} }
    let(:http_party_options) do
      {
          headers: {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
            'Authorization' => "Bearer #{temp_access_token}",
            'Ocp-Apim-Subscription-Key' => api_subscription_key
          },
          body: body,
          query: params,
          timeout: 30,
      }
    end
    let(:path) { '/blah/blah' }

    before { expect(client).to receive(:full_url).with(path).and_call_original }

    it 'returns the results if they are present' do
      expect(HTTParty).to receive(:get).with("#{client.base_url}/blah/blah", http_party_options).and_return(resp)
      expect(resp).to receive(:success?).and_return(true)
      expect(client.get_booker_resources(:get, path, params, body)).to eq [data]
    end

    context 'model passed in and no Results' do
      let(:parsed_response) { {'Treatments' => [data]} }

      it 'returns the services if they are present and results is not' do
        expect(HTTParty).to receive(:get).with("#{client.base_url}/blah/blah", http_party_options).and_return(resp)
        expect(resp).to receive(:success?).and_return(true)
        expect(client.get_booker_resources(:get, path, params, body, Booker::V4::Models::Treatment)).to eq [data]
      end

      context 'singular response' do
        let(:parsed_response) { {'Treatment' => data } }

        it 'returns the data' do
          expect(HTTParty).to receive(:get).with("#{client.base_url}/blah/blah", http_party_options).and_return(resp)
          expect(resp).to receive(:success?).and_return(true)
          expect(client.get_booker_resources(:get, path, params, body, Booker::V4::Models::Treatment)).to eq data
        end
      end
    end

    context 'no Results' do
      let(:resp) { instance_double(HTTParty::Response, parsed_response: parsed_response, code: 200) }
      let(:parsed_response) { {'Foo' => []} }

      it 'returns the parsed response' do
        expect(HTTParty).to receive(:get).with("#{client.base_url}/blah/blah", http_party_options).and_return(resp)
        expect(resp).to receive(:success?).and_return(true)
        expect(client.get_booker_resources(:get, path, params, body)).to eq parsed_response
      end
    end

    context 'response not present on first request' do
      let(:resp) { instance_double(HTTParty::Response, parsed_response: {}, code: 200) }
      let(:resp2) { instance_double(HTTParty::Response, parsed_response: {'Results' => [data]}, code: 200) }

      it 'makes another request, returns results' do
        expect(HTTParty).to receive(:get).with("#{client.base_url}/blah/blah", http_party_options).and_return(resp)
        expect(resp).to receive(:success?).and_return(true)
        expect(client).to_not receive(:sleep)
        expect(HTTParty).to receive(:get).with("#{client.base_url}/blah/blah", http_party_options).and_return(resp2)
        expect(resp2).to receive(:success?).and_return(true)
        expect(client.get_booker_resources(:get, path, params, body)).to eq [data]
      end

      context 'no Results' do
        let(:resp2) { instance_double(HTTParty::Response, parsed_response: {'Results' => []}, code: 200) }

        it 'returns the parsed response' do
          expect(HTTParty).to receive(:get).with("#{client.base_url}/blah/blah", http_party_options).and_return(resp)
          expect(resp).to receive(:success?).and_return(true)
          expect(client).to_not receive(:sleep).with(1)
          expect(HTTParty).to receive(:get).with("#{client.base_url}/blah/blah", http_party_options).and_return(resp2)
          expect(resp2).to receive(:success?).and_return(true)
          expect(client.get_booker_resources(:get, path, params, body)).to eq []
        end
      end

      context 'no response on second request' do
        let(:resp2) { instance_double(HTTParty::Response, parsed_response: {}, code: 200) }

        it 'raises Booker::Error' do
          expect(HTTParty).to receive(:get).with("#{client.base_url}/blah/blah", kind_of(Hash)).and_return(resp)
          expect(resp).to receive(:success?).and_return(true)
          expect(client).to_not receive(:sleep)
          expect(HTTParty).to receive(:get).with("#{client.base_url}/blah/blah", kind_of(Hash)).and_return(resp2)
          expect(resp2).to receive(:success?).and_return(true)
          expect(Booker::Error).to receive(:new).with(url: "#{client.base_url}/blah/blah", request: kind_of(Hash), response: resp).and_call_original
          expect(Booker::Error).to receive(:new).with(url: "#{client.base_url}/blah/blah", request: kind_of(Hash), response: resp2).twice.and_call_original
          expect{client.get_booker_resources(:get, path, params, body)}.to raise_error(Booker::Error)
        end
      end
    end

    context 'response not successful on first request' do
      let(:resp) { instance_double(HTTParty::Response, parsed_response: {'Results' => [data]}, code: 500) }
      let(:resp2) { instance_double(HTTParty::Response, parsed_response: {'Results' => [data]}, code: 200) }

      it 'makes another request, returns results' do
        expect(HTTParty).to receive(:get).with("#{client.base_url}/blah/blah", http_party_options).and_return(resp)
        expect(resp).to receive(:success?).and_return(false)
        expect(client).to receive(:sleep).with(1)
        expect(HTTParty).to receive(:get).with("#{client.base_url}/blah/blah", http_party_options).and_return(resp2)
        expect(resp2).to receive(:success?).and_return(true)
        expect(client.get_booker_resources(:get, path, params, body)).to eq [data]
      end
    end

    context 'Net::ReadTimeout on first request' do
      let(:resp2) { instance_double(HTTParty::Response, parsed_response: {'Results' => [data]}, code: 200) }

      it 'makes another request, returns results' do
        expect(HTTParty).to receive(:get).with("#{client.base_url}/blah/blah", http_party_options).and_raise Net::ReadTimeout
        expect(client).to receive(:sleep).with(1)
        expect(HTTParty).to receive(:get).with("#{client.base_url}/blah/blah", http_party_options).and_return(resp2)
        expect(resp2).to receive(:success?).and_return(true)
        expect(client.get_booker_resources(:get, path, params, body)).to eq [data]
      end
    end
  end

  describe '#access_token' do
    let(:original_token) { 'token' }

    context 'booker_temp_access_token present and not expired' do
      before do
        client.temp_access_token = original_token
        client.temp_access_token_expires_at = (Time.zone.now + 1.minute)
      end

      it 'returns the booker_temp_access_token' do
        expect(client.access_token).to eq original_token
      end
    end

    context 'booker_temp_access_token present, but is expired' do
      before do
        client.temp_access_token = original_token
        client.temp_access_token_expires_at = (Time.zone.now - 1.minute)
      end

      it 'returns the updated booker_temp_access_token' do
        expect(client).to receive(:get_access_token).and_return('new token')
        expect(client.access_token).to eq 'new token'
      end
    end

    context 'booker_temp_access_token nil and is not expired' do
      before do
        client.temp_access_token = nil
        client.temp_access_token_expires_at = (Time.zone.now + 1.minute)
      end

      it 'returns the updated booker_temp_access_token' do
        expect(client).to receive(:get_access_token).and_return('new token')
        expect(client.access_token).to eq 'new token'
      end
    end
  end

  describe '#handle_errors!' do
    let(:resp) { instance_double(HTTParty::Response, parsed_response: parsed_response, code: response_code) }
    let(:parsed_response) { {} }
    let(:request) { 'request' }
    let(:url) { 'url' }
    let(:response_code) { 200 }

    before { allow(client).to receive(:get_access_token).and_return true }

    it 'raises API Gateway errors' do
      described_class::API_GATEWAY_ERRORS.each do |k, v|
        next if k == 401
        response = instance_double(HTTParty::Response, code: k, parsed_response: {})
        expect{ client.send(:handle_errors!, url, request, response) }.to raise_error v
      end
    end

    context 'booker error present' do
      context 'invalid_client' do
        let(:parsed_response) { {'error' => 'invalid_client'} }

        it 'raises Booker::Error' do
          expect{client.handle_errors!('url', 'foo', resp)}.to raise_error(Booker::InvalidApiCredentials)
        end
      end

      context 'invalid access token' do
        let(:parsed_response) { {'error' => 'invalid access token'} }

        context 'get_access_token_data raises error' do
          before { expect(client).to receive(:get_access_token).and_raise(StandardError) }

          it 'raises' do
            expect{client.handle_errors!('url', 'foo', resp)}.to raise_error(StandardError)
          end
        end

        context 'update_access_token_data does not raise error' do
          before { expect(client).to receive(:get_access_token).and_return true }

          it 'sets credentials verified to true and returns nil' do
            expect(client.handle_errors!('url', 'foo', resp)).to be nil
          end
        end
      end

      context 'no error match' do
        let(:parsed_response) { {'error' => 'blah error'} }

        it 'raises Booker::Error' do
          expect(Booker::Error).to receive(:new).with(url: 'url', request: 'foo', response: resp).and_call_original
          expect{client.handle_errors!('url', 'foo', resp)}.to raise_error(Booker::Error)
        end
      end
    end

    context 'response unsuccessful' do
      before do
        allow(resp).to receive(:success?).and_return(false)
      end

      it 'raises Booker::Error' do
        expect(Booker::Error).to receive(:new).with(url: 'url', request: 'foo', response: resp).and_call_original
        expect{client.handle_errors!('url', 'foo', resp)}.to raise_error(Booker::Error)
      end

      context 'status code of 401' do
        let(:response_code) { 401 }

        it 'gets a new token' do
          expect(client.handle_errors!('url', 'foo', resp)).to be nil
          expect(client).to have_received(:get_access_token)
        end
      end

      context 'status code of 403' do
        let(:response_code) { 403 }

        it 'raises Booker::InvalidApiCredentials' do
          expect{ client.handle_errors!('url', 'foo', resp) }.to raise_error Booker::InvalidApiCredentials
        end
      end
    end

    context 'successful response' do
      before { expect(resp).to receive(:success?).and_return(true) }

      it 'returns the resp' do
        expect(client.handle_errors!('url', 'foo', resp))
      end
    end
  end

  describe '#update_token_store' do
    after { client.update_token_store }

    it 'calls the token store with the correct method and args' do
      expect(token_store).to receive(token_store_callback_method).with(temp_access_token, temp_access_token_expires_at)
    end

    context 'token store not present' do
      let(:token_store) { '' }

      it 'does not call the token store' do
        expect(token_store).to_not receive(token_store_callback_method)
      end
    end

    context 'token_store_callback_method store nil' do
      let(:token_store_callback_method) { '' }

      it 'does not call the token store' do
        expect(token_store).to_not receive(token_store_callback_method)
      end
    end
  end

  describe '#get_access_token' do
    let(:temp_access_token) { nil }
    let(:temp_access_token_expires_at) { Time.now + 1.day }
    let(:auth_with_client_credentials) { true }
    let(:refresh_token) { nil }
    let(:access_token) { 'access_token' }
    let(:response) { instance_double(HTTParty::Response, parsed_response: parsed_response) }
    let(:parsed_response) do
      {
        'access_token' => access_token
      }
    end
    let(:result) { client.get_access_token }
    let!(:jwt_stubs) do
      allow_any_instance_of(described_class).to receive(:token_expires_at)
                                                  .with(access_token).and_return temp_access_token_expires_at
    end

    context 'auth_with_client_credentials is true' do
      before do
        expect(client).to receive(:access_token_response).and_return(response)
        expect(client).to receive(:update_token_store).with(no_args)
      end

      it 'sets token info and returns a temp access token' do
        expect(client).to_not receive(:get_location_access_token)
        expect(result).to eq access_token
        expect(result).to eq client.temp_access_token
        expect(client.temp_access_token_expires_at).to be temp_access_token_expires_at
      end

      context 'client has location_id' do
        let(:location_token) { 'location token' }
        let(:location_id) { 31415926 }
        let!(:jwt_stubs) do
          allow_any_instance_of(described_class).to receive(:token_expires_at)
                                                      .with(location_token).and_return temp_access_token_expires_at
        end

        before { expect(client).to receive(:get_location_access_token).and_return location_token }

        it 'gets a location access token and returns it as temp access token' do
          expect(result).to eq location_token
          expect(result).to eq client.temp_access_token
          expect(client.temp_access_token_expires_at).to be temp_access_token_expires_at
        end
      end
    end

    context 'refresh token and location_id' do
      let(:location_id) { 31415926 }
      let(:auth_with_client_credentials) { false }
      let(:refresh_token) { 'refresh_token' }

      before do
        expect(client).to receive(:access_token_response).and_return(response)
        expect(client).to receive(:update_token_store).with(no_args)
      end

      it 'sets token info and returns a temp access token, ignores location_id' do
        expect(client).to_not receive(:get_location_access_token)
        expect(result).to eq access_token
        expect(result).to eq client.temp_access_token
        expect(client.temp_access_token_expires_at).to be temp_access_token_expires_at
      end
    end

    context 'neither refresh token nor auth_with_client_credentials' do
      let(:auth_with_client_credentials) { false }

      before do
        expect(client).to_not receive(:access_token_response)
        expect(client).to_not receive(:update_token_store)
      end

      it 'raises' do
        expect{result}.to raise_error(
          ArgumentError,
          'Cannot get new access token without auth_with_client_credentials or a refresh_token'
        )
      end
    end
  end

  describe '#access_token_response' do
    let(:url) { "#{base_url}/v5/auth/connect/token" }

    context 'auth_with_client_credentials' do
      let(:auth_with_client_credentials) { true }
      let(:options) do
        {
          headers: {
            'Content-Type' => described_class::CREATE_TOKEN_CONTENT_TYPE,
            'Ocp-Apim-Subscription-Key' => api_subscription_key
          },
          body: {
            grant_type: described_class::CLIENT_CREDENTIALS_GRANT_TYPE,
            client_id: client_id,
            client_secret: client_secret,
            scope: access_token_scope
          }.to_query,
          timeout: 30
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

    context 'with refresh token' do
      let(:auth_with_client_credentials) { false }
      let(:options) do
        {
          headers: {
            'Content-Type' => described_class::CREATE_TOKEN_CONTENT_TYPE,
            'Ocp-Apim-Subscription-Key' => api_subscription_key
          },
          body: {
            grant_type: described_class::REFRESH_TOKEN_GRANT_TYPE,
            client_id: client_id,
            client_secret: client_secret,
            scope: access_token_scope,
            refresh_token: refresh_token
          }.to_query,
          timeout: 30
        }
      end
      let(:resp) { instance_double(HTTParty::Response, success?: true, code: 201, parsed_response: {}) }

      before { expect(HTTParty).to receive(:post).with(url, options).and_return resp }

      context 'success' do
        it 'returns response' do
          expect(client.access_token_response).to eq resp
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
          'Ocp-Apim-Subscription-Key' => api_subscription_key,
          'Accept' => 'application/json',
          'Authorization' => "Bearer #{original_token}"
        },
        query: {
          locationId: location_id
        },
        timeout: 30
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

  describe '#full_url' do
    let(:scheme) { 'http://' }
    let(:path) { "#{scheme}foo.com/path" }

    it 'returns path if fully qualified url' do
      expect(client.full_url(path)).to eq path
    end

    context 'no scheme in path' do
      let(:scheme) { '' }

      it 'returns base url plus path if no scheme' do
        expect(client.full_url(path)).to eq "#{base_url}#{path}"
      end
    end
  end

  describe 'private #token_scope' do
    let(:client) { described_class.new }
    let(:token_scope) { 'scope' }
    let(:info) { { 'scope' => token_scope } }
    let(:token) { 'token' }
    let!(:jwt_stubs) { expect(client).to receive(:decoded_token_info).with(token).and_return info  }

    it 'parses exp from decoded token' do
      expect(client.send(:token_scope, token)).to eq token_scope
    end
  end

  describe 'private #token_expires_at' do
    let(:client) { described_class.new }
    let(:exp) { Time.parse('2017-01-01').to_i }
    let(:info) { { 'exp' => exp } }
    let(:token) { 'token' }
    let!(:jwt_stubs) { expect(client).to receive(:decoded_token_info).with(token).and_return info  }

    it 'parses exp from decoded token' do
      expect(client.send(:token_expires_at, token)).to eq Time.parse('2017-01-01')
    end
  end

  describe 'private #decoded_token_info' do
    let(:info) { 'info' }
    let(:decoded_token) { [info] }
    let(:token) { 'token' }

    before do
      expect(JWT).to receive(:decode).with(token, nil, false, verify_not_before: false).and_return decoded_token
    end

    it 'JWT.decode' do
      expect(client.send(:decoded_token_info, token)).to eq info
    end
  end
end
