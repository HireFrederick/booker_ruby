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
    context 'when response is present' do
      it 'sets error data' do
        error = Booker::Error.new(request: 'foo', response: {'error' => 'error', 'error_description' => 'description','ErrorMessage' => 'ErrorMessage'})
        expect(error.error).to eq 'error'
        expect(error.description).to eq 'description'
      end

      context 'when error is not present, but ErrorMessage is' do
        it 'sets error data' do
          error = Booker::Error.new(request: 'foo', response: {'error_description' => 'description', 'ErrorMessage' => 'ErrorMessage'})
          expect(error.error).to eq 'ErrorMessage'
          expect(error.description).to eq 'description'
        end
      end
    end

    context 'when request is present' do
      it 'sets request data' do
        error = Booker::Error.new(request: 'foo')
        expect(error.request).to eq 'foo'
      end
    end

    context 'when no response' do
      it 'sets all things to nil' do
        error = Booker::Error.new
        expect(error.error).to be_nil
        expect(error.description).to be_nil
        expect(error.request).to be_nil
      end
    end

    context 'when url is present' do
      it 'sets url' do
        error = Booker::Error.new(url: 'foo')
        expect(error.url).to eq 'foo'
      end
    end
  end
end

describe Booker::InvalidApiCredentials do
  it 'should be a Booker::Error' do
    expect(Booker::InvalidApiCredentials.new).to be_a(Booker::Error)
  end
end
