require 'spec_helper'

describe Booker::Models::Price do
  it 'has the correct attributes' do
    ['Amount', 'CurrencyCode'].each do |attr|
      expect(subject).to respond_to(attr)
      expect(subject).to respond_to("#{attr}=")
    end
  end
end
