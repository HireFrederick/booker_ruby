module Booker
  module V4
    module Models
      class Room < Model
        attr_accessor 'Capacity',
          'Description',
          'ID',
          'LocationID',
          'Name',
          'Treatments'
      end
    end
  end
end
