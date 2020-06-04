module Booker
  module V4
    module Models
      class PriceRange < Model
        attr_accessor 'From',
                      'To',
                      'DiscountType',
                      'DiscountAmount'
      end
    end
  end
end
