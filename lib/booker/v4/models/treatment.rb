module Booker
  module V4
    module Models
      class Treatment < Model
        attr_accessor 'ID',
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
      end
    end
  end
end
