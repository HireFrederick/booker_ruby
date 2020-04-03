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
                      'DateCreatedOffset',
                      'DateLastModifiedOffset',
                      'DepositOptions',
                      'Description',
                      'DisplayName',
                      'DoesNotRequireStaff',
                      'DurationType',
                      'EmployeeTreatments',
                      'ImageURL',
                      'IsActive',
                      'IsClass',
                      'IsDeleted',
                      'IsForCouples',
                      'MaxTreatmentDuration',
                      'MinTreatmentDuration',
                      'Name',
                      'Price',
                      'RequiresTwoTechnicians',
                      'SubCategory',
                      'TotalDuration',
                      'TreatmentDuration'

        def self.response_results_key
          'Treatment'
        end
      end
    end
  end
end
