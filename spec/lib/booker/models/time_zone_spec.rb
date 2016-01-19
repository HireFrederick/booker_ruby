require 'spec_helper'

describe Booker::Models::TimeZone do
  it 'has the correct attributes' do
    ['ID', 'Name', 'StandardName'].each do |attr|
      expect(subject).to respond_to(attr)
      expect(subject).to respond_to("#{attr}=")
    end
  end
end
