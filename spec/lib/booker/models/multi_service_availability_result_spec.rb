require 'spec_helper'

describe Booker::Models::MultiServiceAvailabilityResult do
  it 'has the correct attributes' do
    ['ItineraryTimeSlotsLists'].each do |attr|
      expect(subject).to respond_to(attr)
    end
  end
end
