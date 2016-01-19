require 'spec_helper'

describe Booker::Error do
  describe '.new' do
    context 'when response is present' do
      it 'sets error data' do
        error = Booker::Error.new('foo', {'error' => 'error', 'error_description' => 'description', 'ErrorMessage' => 'ErrorMessage'})
        expect(error.error).to eq 'error'
        expect(error.description).to eq 'description'
      end

      context 'when error is not present, but ErrorMessage is' do
        it 'sets error data' do
          error = Booker::Error.new('foo', {'error_description' => 'description', 'ErrorMessage' => 'ErrorMessage'})
          expect(error.error).to eq 'ErrorMessage'
          expect(error.description).to eq 'description'
        end
      end
    end

    context 'when request is present' do
      it 'sets request data' do
        error = Booker::Error.new('foo')
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
  end
end

describe Booker::InvalidApiCredentials do
  it 'should be a Booker::Error' do
    expect(Booker::InvalidApiCredentials.new).to be_a(Booker::Error)
  end
end
