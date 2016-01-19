require 'spec_helper'

describe Booker::Models::ClassInstance do
  it 'has the correct attributes' do
    ['ID',
      'EndDateTime',
      'HasClassFilled',
      'IsForMembersOnly',
      'IsRecurring',
      'IsSpecialEvent',
      'IsWorkshop',
      'NumReserved',
      'Price',
      'RoomName',
      'StartDateTime',
      'Teacher',
      'Teacher2',
      'TotalCapacity',
      'TreatmentDuration',
      'ListAsSubstitute',
      'IsEnrollable',
      'SeriesID',
      'Treatment'].each do |attr|
      expect(subject).to respond_to(attr)
      expect(subject).to respond_to("#{attr}=")
    end
  end
end
