require 'spec_helper'

describe Booker::Models::AvailableTime do
  it 'has the correct attributes' do
    ['CurrentPrice',
      'Duration',
      'EmployeeID',
      'StartDateTime',
      'TreatmentID',
      'RoomID',
      'Employee2ID'].each do |attr|
      expect(subject).to respond_to(attr)
      expect(subject).to respond_to("#{attr}=")
    end
  end
end
