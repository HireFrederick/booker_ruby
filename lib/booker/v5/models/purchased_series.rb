module Booker
  module V5
    module Models
      class PurchasedSeries < Model
        attr_accessor 'Id',
                      'CustomerId',
                      'OriginalQuantity',
                      'RemainingQuantity',
                      'QuantityUsed',
                      'SeriesNumber',
                      'SeriesId',
                      'Status',
                      'DateIssued',
                      'ExpirationDate',
                      'DateLastModified',
                      'PurchasePrice'
      end
    end
  end
end
