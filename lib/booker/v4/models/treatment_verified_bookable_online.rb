module Booker
  module V4
    module Models
      class TreatmentVerifiedBookableOnline < Model
        attr_accessor 'ID',
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
      end
    end
  end
end
