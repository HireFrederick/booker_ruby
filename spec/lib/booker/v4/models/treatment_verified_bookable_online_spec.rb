require 'spec_helper'

describe Booker::V4::Models::TreatmentVerifiedBookableOnline do
  it { is_expected.to be_a Booker::V4::Models::Model }

  it 'has the correct attributes' do
    [
      'ID',
      'AllowCustomersToBookOnline',
      'AvailableInAdvance',
      'AvailableInAdvanceDateUnitType',
      'Category',
      'ColorCode',
      'CustomerRecordType',
      'CustomerTypeID',
      'CustomerTypeName',
      'DateCreatedOffset',
      'DateLastModifiedOffset',
      'DepositOptions',
      'Description',
      'DisplayName',
      'DoesNotRequireStaff',
      'DurationType',
      'EmployeeTreatments',
      'FlexiblePriceIncrementType',
      'ImageURL',
      'IsActive',
      'IsBoundingService',
      'IsClass',
      'IsDeleted',
      'IsFlexiblePrice',
      'IsForCouples',
      'IsSharedService',
      'MaxTreatmentDuration',
      'MinTreatmentDuration',
      'Name',
      'Price',
      'RequiresTwoTechnicians',
      'SharedRoomGuestCount',
      'SubCategory',
      'TotalDuration',
      'TreatmentDuration'
    ].each do |attr|
      expect(subject).to respond_to(attr)
      expect(subject).to respond_to("#{attr}=")
    end
  end
end
