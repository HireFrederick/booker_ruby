require 'spec_helper'

describe Booker::V4::Models::Special do
  it { is_expected.to be_a Booker::V4::Models::Model }

  it 'has the correct attributes' do
    [
      'ID',
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
    ].each do |attr|
      expect(subject).to respond_to(attr)
      expect(subject).to respond_to("#{attr}=")
    end
  end
end
