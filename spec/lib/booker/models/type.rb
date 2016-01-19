require 'spec_helper'

describe Booker::Models::Type do
  it 'has the correct attributes' do
    ['ID', 'Name'].each do |attr|
      expect(subject).to respond_to(attr)
      expect(subject).to respond_to("#{attr}=")
    end
  end
end
