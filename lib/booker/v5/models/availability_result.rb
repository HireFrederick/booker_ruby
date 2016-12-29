module Booker
  module V5
    module Models
      class AvailabilityResult < Model
        attr_accessor 'locationId',
          'startTimeInterval',
          'locationHours',
          'serviceCategories'
      end
    end
  end
end
