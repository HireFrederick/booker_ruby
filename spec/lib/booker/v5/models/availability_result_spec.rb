require 'spec_helper'

describe Booker::V5::Models::AvailabilityResult do
  it { is_expected.to be_a Booker::V5::Models::Model }

  it 'has the correct attributes' do
    %w(locationId startTimeInterval locationHours serviceCategories).each do |attr|
      expect(subject).to respond_to(attr)
    end
  end
end
