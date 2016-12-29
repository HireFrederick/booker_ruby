module Booker
  module V4
    module Models
      class DynamicPrice < Model
        attr_accessor 'Discount',
          'FinalPrice',
          'OriginalPrice',
          'ReceiptDisplayPrice',
          'OriginalTagPrice'
      end
    end
  end
end
