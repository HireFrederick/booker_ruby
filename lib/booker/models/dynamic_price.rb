module Booker
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
