module Booker
  module V4
    module Models
      class Address < Model
        attr_accessor 'Street1',
                      'Street2',
                      'City',
                      'State',
                      'Zip',
                      'Country'
      end
    end
  end
end
