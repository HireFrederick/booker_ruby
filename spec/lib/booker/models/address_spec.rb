require 'spec_helper'

describe Booker::Models::Address do
  it 'has the correct attributes' do
    ['Street1', 'Street2', 'City', 'State', 'Zip', 'Country'].each do |attr|
      expect(subject).to respond_to(attr)
    end
  end
end
