require 'spec_helper'

describe Booker::Models::FeatureSettings do
  it 'has the correct attributes' do
    ['UseFrederick', 'UsePromote'].each do |attr|
      expect(subject).to respond_to(attr)
    end
  end
end
