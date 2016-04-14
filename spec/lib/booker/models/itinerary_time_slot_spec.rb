require 'spec_helper'

describe Booker::Models::ItineraryTimeSlot do
  it 'has the correct attributes' do
    ['TreatmentTimeSlots'].each do |attr|
      expect(subject).to respond_to(attr)
    end
  end
end
