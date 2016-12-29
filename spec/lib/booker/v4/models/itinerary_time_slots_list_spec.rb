require 'spec_helper'

describe Booker::V4::Models::ItineraryTimeSlotsList do
  it { is_expected.to be_a Booker::V4::Models::Model }

  it 'has the correct attributes' do
    ['ItineraryTimeSlots'].each do |attr|
      expect(subject).to respond_to(attr)
    end
  end
end
