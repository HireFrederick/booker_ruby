require 'spec_helper'

describe Booker::V4::Models::EmployeeTreatment do
  it { is_expected.to be_a Booker::V4::Models::Model }

  it 'has the correct attributes' do
    [
      'EmployeeID',
      'FinishTimeDuration',
      'ProcessingTimeDuration',
      'RequestedPrice',
      'TotalDuration',
      'TreatmentDuration'
    ].each do |attr|
      expect(subject).to respond_to(attr)
      expect(subject).to respond_to("#{attr}=")
    end
  end
end
