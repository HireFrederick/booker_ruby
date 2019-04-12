require 'spec_helper'

describe Booker::V5::Models::PurchasedSeries do
  it { is_expected.to be_a Booker::V5::Models::Model }

  it 'has the correct attributes' do
    %w(Id CustomerId OriginalQuantity RemainingQuantity QuantityUsed SeriesNumber SeriesId Status DateIssued
       ExpirationDate DateLastModified PurchasePrice).each do |attr|
      expect(subject).to respond_to(attr)
    end
  end
end
