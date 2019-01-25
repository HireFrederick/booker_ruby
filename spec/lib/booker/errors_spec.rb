require 'spec_helper'

describe Booker::Error do
  describe 'attributes' do
    it { expect(subject).to respond_to :url }
    it { expect(subject).to respond_to :error }
    it { expect(subject).to respond_to :description }
    it { expect(subject).to respond_to :request }
    it { expect(subject).to respond_to :response }
    it { expect(subject).to respond_to :url= }
    it { expect(subject).to respond_to :error= }
    it { expect(subject).to respond_to :description= }
    it { expect(subject).to respond_to :request= }
    it { expect(subject).to respond_to :response= }
  end

  describe '.new' do
    let(:response) { instance_double(HTTParty::Response, parsed_response: parsed_response) }

    context 'response is present' do
      let(:error) { Booker::Error.new(response: response) }

      let(:parsed_response) do
        {
          'error' => 'error',
          'error_description' => 'description',
          'ErrorMessage' => 'ErrorMessage'
        }
      end

      it 'sets error data' do
        expect(error.error).to eq 'error'
        expect(error.description).to eq 'description'
        expect(error.request).to be_nil
      end

      context 'when error is not present, but ErrorMessage is' do
        let(:parsed_response) do
          {
            'error_description' => 'description',
            'ErrorMessage' => 'ErrorMessage'
          }
        end

        it 'sets error data' do
          expect(error.error).to eq 'ErrorMessage'
          expect(error.description).to eq 'description'
        end
      end
    end

    context 'request is present' do
      let(:error) { Booker::Error.new(request: 'foo') }

      it 'sets request data' do
        expect(error.request).to eq 'foo'
        expect(error.error).to be_nil
        expect(error.description).to be_nil
      end
    end

    context 'url is present' do
      let(:error) { Booker::Error.new(url: 'foo') }

      it 'sets url' do
        expect(error.url).to eq 'foo'
      end
    end
  end
end

describe Booker::MidPaginationError do
  describe 'attributes' do
    it { expect(subject).to respond_to :error_occurred_during_params }
    it { expect(subject).to respond_to :results_fetched_prior_to_error }
    it { expect(subject).to respond_to :message }
    it { expect(subject).to respond_to :error_occurred_during_params= }
    it { expect(subject).to respond_to :results_fetched_prior_to_error= }
    it { expect(subject).to respond_to :message= }
  end

  describe '.new' do
    let(:error) do
      Booker::MidPaginationError.new(message: message, error_occurred_during_params: error_occurred_during_params,
                                     results_fetched_prior_to_error: results_fetched_prior_to_error)
    end
    let(:message) { "Error occurred during call mid-pagination" }
    before do
      expect(error.error_occurred_during_params).to eq error_occurred_during_params
      expect(error.results_fetched_prior_to_error).to eq results_fetched_prior_to_error
      expect(error.message).to eq message
    end

    context 'when all attributes defined' do
      let(:error_occurred_during_params) { {PageSize: 1} }
      let(:results_fetched_prior_to_error) { ['prior results'] }
      let(:message) { "Special message" }

      it 'sets error data' do; end
    end
    context 'when attributes undefined' do
      let(:error_occurred_during_params) { {} }
      let(:results_fetched_prior_to_error) { [] }

      it 'sets defaults' do; end
    end
  end
end

describe Booker::InvalidApiCredentials do
  it 'should be a Booker::Error' do
    expect(Booker::InvalidApiCredentials.new).to be_a(Booker::Error)
  end
end

describe Booker::ServiceUnavailable do
  it 'should be a Booker::Error' do
    expect(Booker::ServiceUnavailable.new).to be_a(Booker::Error)
  end
end

describe Booker::RateLimitExceeded do
  it 'should be a Booker::Error' do
    expect(Booker::RateLimitExceeded.new).to be_a(Booker::Error)
  end
end
