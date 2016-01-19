require 'spec_helper'

describe Booker::Models::SpaEmployeeAvailabilitySearchItem do
  it 'has the correct attributes' do
    ['AvailableTimes', 'Treatment', 'FirstAvailableTime', 'CurrentPrice', 'Spa'].each do |attr|
      expect(subject).to respond_to(attr)
      expect(subject).to respond_to("#{attr}=")
    end
  end
end
