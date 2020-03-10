module Booker
  module V4
    module Models
      class EmployeeTreatment < Model
        attr_accessor 'EmployeeID',
                      'FinishTimeDuration',
                      'ProcessingTimeDuration',
                      'RequestedPrice',
                      'TotalDuration',
                      'TreatmentDuration'
      end
    end
  end
end
