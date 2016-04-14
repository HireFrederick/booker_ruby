require 'spec_helper'

describe Booker::Models::TreatmentTimeSlot do
  it 'has the correct attributes' do
    ['AvailableTimes'].each do |attr|
      expect(subject).to respond_to(attr)
    end
  end
end
