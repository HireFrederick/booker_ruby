module Booker
  module V4
    module Models
      class Special < Model
        attr_accessor 'ID',
                      'LocationID',
                      'Name',
                      'Description',
                      'CouponCode',
                      'Type',
                      'ShortUrl',
                      'ApplicableStartDate',
                      'ApplicableEndDate',
                      'BookingStartDate',
                      'BookingEndDate',
                      'MaxRedemptions',
                      'TimeOfDayStart',
                      'TimeOfDayEnd',
                      'HasTreatment',
                      'WeekDays',
                      'UsePriceRanges',
                      'PriceRanges',
                      'DiscountType',
                      'AdjustmentType',
                      'DiscountAmount',
                      'CanCustomerDirectBook',
                      'HideOnInvoicesAndReceipts',
                      'PhotoUrl',
                      'UsedRedemptions',
                      'AvailableRedemptions',
                      'HasFreeItems',
                      'ApplicationItemIDs',
                      'IsExclusiveWithAll',
                      'IsExclusiveWithAny',
                      'CombinationRules',
                      'ApplicableStartDateOffset',
                      'ApplicableEndDateOffset',
                      'BookingStartDateOffset',
                      'BookingEndDateOffset',
                      'TimeOfDayStartOffset',
                      'TimeOfDayEndOffset'
      end
    end
  end
end
