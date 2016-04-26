require 'spec_helper'

describe Booker::Client do
  let(:base_url) { 'http://foo' }
  let(:client_id) { 'client_id' }
  let(:client_secret) { 'client_secret' }
  let(:temp_access_token) { 'temp_access_token' }
  let(:temp_access_token_expires_at) { Time.now + 1.minute }
  let(:client) do
    Booker::Client.new(
        base_url: base_url,
        temp_access_token: temp_access_token,
        temp_access_token_expires_at: temp_access_token_expires_at,
        client_id: client_id,
        client_secret: client_secret,
        token_store: token_store,
        token_store_callback_method: token_store_callback_method
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

  describe 'constants' do
    it 'sets constants to right vals' do
      expect(described_class::ACCESS_TOKEN_HTTP_METHOD).to eq :get
      expect(described_class::ACCESS_TOKEN_ENDPOINT).to eq '/access_token'
      expect(described_class::TimeZone).to eq 'Eastern Time (US & Canada)'
    end
  end

  describe '.new' do
    before do
      allow(ENV).to receive(:[]).with('BOOKER_CLIENT_ID').and_return 'id from env'
      allow(ENV).to receive(:[]).with('BOOKER_CLIENT_SECRET').and_return 'secret from env'
    end

    it 'builds a client with the valid options given' do
      expect(client.base_url).to eq base_url
      expect(client.temp_access_token).to eq temp_access_token
      expect(client.temp_access_token_expires_at).to eq temp_access_token_expires_at
      expect(client.client_id).to eq client_id
      expect(client.client_secret).to eq client_secret
    end

    context 'without client_id specified' do
      let(:client) { Booker::Client.new }

      it 'loads from ENV' do
        expect(client.client_id).to eq 'id from env'
        expect(client.client_secret).to eq 'secret from env'
      end
    end
  end

  describe '#get_base_url' do
    let(:env_base_url_key) { 'foo' }

    before { expect(client).to receive(:env_base_url_key).with(no_args).and_return(env_base_url_key) }

    context 'no urls' do
      let(:default_base_url) { nil }

      before { expect(client).to receive(:default_base_url).with(no_args).and_return(default_base_url) }

      it 'returns nil' do
        expect(client.get_base_url).to eq nil
      end
    end

    context 'env_base_url_key returns value from ENV' do
      let(:env_url) { 'env_url' }

      before do
        expect(ENV).to receive(:[]).with(env_base_url_key).and_return(env_url)
        expect(client).to_not receive(:default_base_url)
      end

      it 'returns env_url' do
        expect(client.get_base_url).to eq env_url
      end
    end

    context 'default_base_url returns val' do
      let(:default_base_url) { 'default_base_url' }

      before { expect(client).to receive(:default_base_url).with(no_args).and_return(default_base_url) }

      it 'returns nil' do
        expect(client.get_base_url).to eq default_base_url
      end
    end
  end

  describe '#get' do
    let(:http_party_options) {
      {
          headers: {"Content-Type"=>"application/json; charset=utf-8"},
          query: data,
          timeout: 120
      }
    }
    let(:data) { {data: 'datum'} }
    let(:resp) { {'Results' => [data]} }

    it 'makes the request using the options given' do
      expect(client).to receive(:get_booker_resources).with(:get, '/blah/blah', data, nil, Booker::Models::Model).and_call_original
      expect(HTTParty).to receive(:get).with("#{client.base_url}/blah/blah", http_party_options).and_return(resp)
      expect(resp).to receive(:success?).and_return(true)
      expect(Booker::Models::Model).to receive(:from_list).with([data]).and_return(['results'])
      expect(client.get('/blah/blah', data, Booker::Models::Model)).to eq ['results']
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
          headers: {"Content-Type"=>"application/json; charset=utf-8"},
          body: post_data.to_json,
          timeout: 120
      }
    }
    let(:data) { {data: 'datum'} }
    let(:resp) { {'Results' => [data]} }
    let(:post_data) { {"lUserID" => 13240029,"lBusinessID" => "25142"} }

    it 'makes the request using the options given' do
      expect(client).to receive(:get_booker_resources).with(:post, '/blah/blah', nil, post_data.to_json, Booker::Models::Model).and_call_original
      expect(HTTParty).to receive(:post).with("#{client.base_url}/blah/blah", http_party_options).and_return(resp)
      expect(resp).to receive(:success?).and_return(true)
      expect(Booker::Models::Model).to receive(:from_list).with([data]).and_return(['results'])
      expect(client.post('/blah/blah', post_data, Booker::Models::Model)).to eq ['results']
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
        headers: {"Content-Type"=>"application/json; charset=utf-8"},
        body: post_data.to_json,
        timeout: 120
      }
    }
    let(:data) { {data: 'datum'} }
    let(:resp) { {'Results' => [data]} }
    let(:post_data) { {"lUserID" => 13240029,"lBusinessID" => "25142"} }

    it 'makes the request using the options given' do
      expect(client).to receive(:get_booker_resources).with(:put, '/blah/blah', nil, post_data.to_json, Booker::Models::Model).and_call_original
      expect(HTTParty).to receive(:put).with("#{client.base_url}/blah/blah", http_party_options).and_return(resp)
      expect(resp).to receive(:success?).and_return(true)
      expect(Booker::Models::Model).to receive(:from_list).with([data]).and_return(['results'])
      expect(client.put('/blah/blah', post_data, Booker::Models::Model)).to eq ['results']
    end

    it 'allows you to not pass in a booker model' do
      expect(HTTParty).to receive(:put).with("#{client.base_url}blah/blah", http_party_options).and_return(resp)
      expect(resp).to receive(:success?).and_return(true)
      expect(client.put('blah/blah', post_data)).to eq [data]
    end
  end

  describe '#paginated_request' do
    let(:path) { '/appointments' }

    context 'valid params' do
      let(:params_1) do
        {
            'UsePaging' => true,
            'PageSize' => 3,
            'PageNumber' => 1
        }
      end
      let(:results) { [result_1, result_2, result_3] }
      let(:result_1) { Booker::Models::Customer.new(LocationID: 123, FirstName: 'Jim') }
      let(:result_2) { Booker::Models::Customer.new(LocationID: 456) }
      let(:result_3) { Booker::Models::Customer.new(LocationID: 123, FirstName: 'Jim') }
      let(:base_paginated_request_args) { {method: 'method', path: path, params: params_1, model: Booker::Models::Model} }
      let(:paginated_request_args) { base_paginated_request_args }

      before { expect(client).to receive(:send).with('method', path, params_1, Booker::Models::Model).and_return(results) }

      context 'fetch all is true' do
        let(:params_2) { params_1.merge('PageNumber' => (params_1['PageNumber'] + 1)) }
        let(:params_3) { params_1.merge('PageNumber' => (params_1['PageNumber'] + 2)) }
        let(:result_4) { Booker::Models::Customer.new(LocationID: 123, FirstName: 'Jim') }
        let(:result_5) { Booker::Models::Customer.new(LocationID: 123, FirstName: 'John') }
        let(:total_missing) { params_2['PageSize'] - results2.length }
        let(:raven_msg) { "Page of #{path} has less records then specified in page size. Ensure this is not last page of request" }
        let(:results2) { [result_4, result_5] }
        let(:results3) { [] }

        before do
          expect(client).to receive(:send).with('method', path, params_2, Booker::Models::Model).and_return(results2)
          expect(client).to receive(:send).with('method', path, params_3, Booker::Models::Model).and_return(results3)
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
              'UsePaging' => val,
              'PageSize' => page_size,
              'PageNumber' => page_number
            }, model: Booker::Models::Model)}.to raise_error(ArgumentError, 'params must include valid PageSize, PageNumber and UsePaging')
        end
      end

      it 'invalid PageSize' do
        [nil, 0].each do |val|
          expect{client.paginated_request(method: 'method', path: path, params: {
              'UsePaging' => use_paging,
              'PageSize' => val,
              'PageNumber' => page_number
            }, model: Booker::Models::Model)}.to raise_error(ArgumentError, 'params must include valid PageSize, PageNumber and UsePaging')
        end
      end

      it 'invalid PageNumber' do
        [nil, 0].each do |val|
          expect{client.paginated_request(method: 'method', path: path, params: {
              'UsePaging' => use_paging,
              'PageSize' => page_size,
              'PageNumber' => val
            }, model: Booker::Models::Model)}.to raise_error(ArgumentError, 'params must include valid PageSize, PageNumber and UsePaging')
        end
      end
    end

    context 'result is not a list' do
      let(:params) {{
        'UsePaging' => true,
        'PageSize' => 2,
        'PageNumber' => 1
      }}

      before do
        expect(client).to receive(:send).with('method', path, params, Booker::Models::Model).and_return('foo')
      end

      it 'raises error' do
        expect{client.paginated_request(method: 'method', path: path, params: params, model: Booker::Models::Model)}.to raise_error(StandardError, "Result from paginated request to #{path} with params: {\"UsePaging\"=>true, \"PageSize\"=>2, \"PageNumber\"=>1} is not a collection")
      end
    end
  end

  describe '#get_booker_resources' do
    let(:data) { {data: 'datum'} }
    let(:resp) { {'Results' => [data]} }
    let(:params) { {foo: 'bar'} }
    let(:body) { {bar: 'foo'} }
    let(:http_party_options) do
      {
          headers: {'Content-Type' => 'application/json; charset=utf-8'},
          body: body,
          query: params,
          timeout: 120
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
      let(:resp) { {'Treatments' => [data]} }

      it 'returns the services if they are present and results is not' do
        expect(HTTParty).to receive(:get).with("#{client.base_url}/blah/blah", http_party_options).and_return(resp)
        expect(resp).to receive(:success?).and_return(true)
        expect(client.get_booker_resources(:get, path, params, body, Booker::Models::Treatment)).to eq [data]
      end

      context 'singular response' do
        let(:resp) { {'Treatment' => data } }

        it 'returns the data' do
          expect(HTTParty).to receive(:get).with("#{client.base_url}/blah/blah", http_party_options).and_return(resp)
          expect(resp).to receive(:success?).and_return(true)
          expect(client.get_booker_resources(:get, path, params, body, Booker::Models::Treatment)).to eq data
        end
      end
    end

    context 'no Results' do
      let(:resp) { {'Foo' => []} }

      it 'returns the full resp' do
        expect(HTTParty).to receive(:get).with("#{client.base_url}/blah/blah", http_party_options).and_return(resp)
        expect(resp).to receive(:success?).and_return(true)
        expect(client.get_booker_resources(:get, path, params, body)).to eq resp
      end
    end

    context 'response not present on first request' do
      let(:resp) { {} }
      let(:resp2) { {'Results' => [data]} }

      it 'makes another request, returns results' do
        expect(HTTParty).to receive(:get).with("#{client.base_url}/blah/blah", http_party_options).and_return(resp)
        expect(resp).to receive(:success?).and_return(true)
        expect(HTTParty).to receive(:get).with("#{client.base_url}/blah/blah", http_party_options).and_return(resp2)
        expect(resp2).to receive(:success?).and_return(true)
        expect(client.get_booker_resources(:get, path, params, body)).to eq [data]
      end

      context 'no Results' do
        let(:resp2) { {'foo' => []} }

        it 'returns the full resp' do
          expect(HTTParty).to receive(:get).with("#{client.base_url}/blah/blah", http_party_options).and_return(resp)
          expect(resp).to receive(:success?).and_return(true)
          expect(HTTParty).to receive(:get).with("#{client.base_url}/blah/blah", http_party_options).and_return(resp2)
          expect(resp2).to receive(:success?).and_return(true)
          expect(client.get_booker_resources(:get, path, params, body)).to eq resp2
        end
      end

      context 'no response on second request' do
        let(:resp2) { {} }

        it 'raises Booker::Error' do
          expect(HTTParty).to receive(:get).with("#{client.base_url}/blah/blah", kind_of(Hash)).and_return(resp)
          expect(resp).to receive(:success?).and_return(true)
          expect(HTTParty).to receive(:get).with("#{client.base_url}/blah/blah", kind_of(Hash)).and_return(resp2)
          expect(resp2).to receive(:success?).and_return(true)
          expect(Booker::Error).to receive(:new).with(url: "#{client.base_url}/blah/blah", request: kind_of(Hash), response: resp).exactly(3).times.and_call_original
          expect{client.get_booker_resources(:get, path, params, body)}.to raise_error(Booker::Error)
        end
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
    let(:resp) { {} }

    context 'booker error present' do
      before { expect(resp).to_not receive(:handle_errors) }

      context 'invalid_client' do
        let(:resp) { {'error' => 'invalid_client'} }

        it 'raises Booker::Error' do
          expect{client.handle_errors!('url', 'foo', resp)}.to raise_error(Booker::InvalidApiCredentials)
        end
      end

      context 'invalid access token' do
        let(:resp) { {'error' => 'invalid access token'} }

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
        let(:resp) { {'error' => 'blah error'} }

        it 'raises Booker::Error' do
          expect(Booker::Error).to receive(:new).with(url: 'url', request: 'foo', response: resp).and_call_original
          expect{client.handle_errors!('url', 'foo', resp)}.to raise_error(Booker::Error)
        end
      end
    end

    context 'response unsuccessful' do
      before { expect(resp).to receive(:success?).and_return(false) }

      it 'raises Booker::Error' do
        expect(Booker::Error).to receive(:new).with(url: 'url', request: 'foo', response: resp).and_call_original
        expect{client.handle_errors!('url', 'foo', resp)}.to raise_error(Booker::Error)
      end
    end

    context 'successful response' do
      before { expect(resp).to receive(:success?).and_return(true) }

      it 'returns the resp' do
        expect(client.handle_errors!('url', 'foo', resp))
      end
    end
  end

  describe '#access_token_options' do
    it 'returns right access_token_options' do
      expect(client.access_token_options).to eq(
                                                 client_id: client_id,
                                                 client_secret: client_secret
                                             )
    end
  end

  describe '#get_access_token' do
    let(:temp_access_token) { nil }
    let(:temp_access_token_expires_at) { nil }
    let(:now) { Time.parse('2015-01-09') }
    let(:expires_in) { 100 }
    let(:expires_at) { now + expires_in }
    let(:access_token) { 'access_token' }
    let(:parsed_response) do
      {
          'expires_in' => expires_in.to_s,
          'access_token' => access_token

      }
    end

    before { allow(Time).to receive(:now).with(no_args).and_return(now) }

    context 'raise_invalid_api_credentials_for_empty_resp! yields' do
      before do
        expect(client).to receive(:raise_invalid_api_credentials_for_empty_resp!).with(no_args).and_call_original
        expect(client).to receive(:get).with('/access_token', http_options, nil).and_return(response)
        expect(response).to receive(:parsed_response).with(no_args).and_return(parsed_response)
        expect(client).to receive(:update_token_store).with(no_args)
      end

      it 'sets token info and returns a temp access token' do
        token = client.get_access_token
        expect(token).to eq access_token
        expect(token).to eq client.temp_access_token
        expect(client.temp_access_token_expires_at).to be_a Time
        expect(client.temp_access_token_expires_at).to eq expires_at
      end
    end

    context 'raise_invalid_api_credentials_for_empty_resp! does not yield' do
      let(:parsed_response) { {} }

      before do
        expect(client).to receive(:raise_invalid_api_credentials_for_empty_resp!).with(no_args)
        expect(client).to_not receive(:get).with('/access_token', http_options, nil)
        expect(response).to_not receive(:parsed_response)
        expect(client).to_not receive(:update_token_store)
      end

      it 'raises Booker::InvalidApiCredentials, does not set token info' do
        expect { client.get_access_token }.to raise_error NoMethodError
        expect(client.temp_access_token_expires_at).to eq nil
        expect(client.temp_access_token).to eq nil
      end
    end
  end

  describe '#raise_invalid_api_credentials_for_empty_resp!' do
    let(:block_string) { 'inside_block' }

    it 'it returns output of block_code' do
      expect(
          client.raise_invalid_api_credentials_for_empty_resp! { block_string }
      ).to be block_string
    end

    context 'block code raises error' do
      let(:block_method) { :to_i }
      let(:request) { 'request' }
      let(:response) { '' }
      let(:exception) { Booker::Error.new(url: 'url', request: request, response: response) }

      before { expect(block_string).to receive(block_method).and_raise(exception) }

      context 'response not present' do
        before { expect(Booker::InvalidApiCredentials).to receive(:new).with(url: 'url', request: request, response: nil).and_call_original }

        it 'raises InvalidApiCredentials' do
          expect{
            client.raise_invalid_api_credentials_for_empty_resp! { block_string.send(block_method) }
          }.to raise_error Booker::InvalidApiCredentials
        end
      end

      context 'response present' do
        let(:response) { 'response' }

        before { expect(Booker::InvalidApiCredentials).to_not receive(:new) }

        it 'raises Booker::Error' do
          expect{
            client.raise_invalid_api_credentials_for_empty_resp! { block_string.send(block_method) }
          }.to raise_error exception.class
        end
      end

      context 'error not booker error' do
        let(:exception) { StandardError }

        before { expect(Booker::InvalidApiCredentials).to_not receive(:new) }

        it 'raises Booker::Error' do
          expect{
            client.raise_invalid_api_credentials_for_empty_resp! { block_string.send(block_method) }
          }.to raise_error exception
        end
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

  describe '#access_token_response' do
    let(:parsed_response) { 'parsed_response' }

    after { expect(client.access_token_response(http_options)).to eq parsed_response }

    it 'calls the token store' do
      expect(client).to receive(described_class::ACCESS_TOKEN_HTTP_METHOD)
                            .with(described_class::ACCESS_TOKEN_ENDPOINT, http_options, nil)
                            .and_return(response)
      expect(response).to receive(:parsed_response).with(no_args).and_return(parsed_response)
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
end
