require 'spec_helper'

describe Booker::V4::Models::ClassInstance do
  it { is_expected.to be_a Booker::V4::Models::Model }

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
      'Treatment',
      'Order'].each do |attr|
      expect(subject).to respond_to(attr)
      expect(subject).to respond_to("#{attr}=")
    end
  end
end
