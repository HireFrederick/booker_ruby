require 'spec_helper'

describe Booker::V4::Models::SpaEmployeeAvailabilitySearchItem do
  it { is_expected.to be_a Booker::V4::Models::Model }

  it 'has the correct attributes' do
    ['AvailableTimes', 'Treatment', 'FirstAvailableTime', 'CurrentPrice', 'Spa'].each do |attr|
      expect(subject).to respond_to(attr)
      expect(subject).to respond_to("#{attr}=")
    end
  end
end
