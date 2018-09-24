module Booker
  module V4
    module Models
      class Order < Model
        attr_accessor 'ID',
			'CustomerID',
			'SavedInProgress',
			'DateCompleted',
			'DatePaid',
			'Status',
			'TotalBeforeTaxes',
			'Items',
			'IsCompleted',
			'OrderNumber'
      end
    end
  end
end
