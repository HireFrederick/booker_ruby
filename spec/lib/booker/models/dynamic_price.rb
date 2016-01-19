require 'spec_helper'

describe Booker::Models::DynamicPrice do
  it 'has the correct attributes' do
    ['Discount',
      'FinalPrice',
      'OriginalPrice',
      'ReceiptDisplayPrice',
      'OriginalTagPrice'].each do |attr|
      expect(subject).to respond_to(attr)
      expect(subject).to respond_to("#{attr}=")
    end
  end
end
