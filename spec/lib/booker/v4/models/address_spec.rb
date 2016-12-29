require 'spec_helper'

describe Booker::V4::Models::Address do
  it { is_expected.to be_a Booker::V4::Models::Model }

  it 'has the correct attributes' do
    ['Street1', 'Street2', 'City', 'State', 'Zip', 'Country'].each do |attr|
      expect(subject).to respond_to(attr)
    end
  end
end
