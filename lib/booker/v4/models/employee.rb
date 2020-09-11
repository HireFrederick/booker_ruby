module Booker
  module V4
    module Models
      class Employee < Model
        attr_accessor 'ID',
                      'FirstName',
                      'LastName',
                      'Gender',
                      'MobilePhone',
                      'Address'
      end
    end
  end
end
