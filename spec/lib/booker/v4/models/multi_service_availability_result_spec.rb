require 'spec_helper'

describe Booker::V4::Models::MultiServiceAvailabilityResult do
  it { is_expected.to be_a Booker::V4::Models::Model }

  it 'has the correct attributes' do
    ['ItineraryTimeSlotsLists'].each do |attr|
      expect(subject).to respond_to(attr)
    end
  end
end
