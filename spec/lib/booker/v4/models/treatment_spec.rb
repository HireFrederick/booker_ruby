require 'spec_helper'

describe Booker::V4::Models::Treatment do
  it { is_expected.to be_a Booker::V4::Models::Model }

  it 'has the correct attributes' do
    [
        'ID',
        'AllowCustomersToBookOnline',
        'Category',
        'Description',
        'Name',
        'Price',
        'SubCategory',
        'TotalDuration',
        'TreatmentDuration',
        'IsClass',
        'IsForCouples',
        'EmployeeIDs',
        'IsActive'
    ].each do |attr|
      expect(subject).to respond_to(attr)
      expect(subject).to respond_to("#{attr}=")
    end
  end
end
