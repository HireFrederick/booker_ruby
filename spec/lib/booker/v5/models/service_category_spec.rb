require 'spec_helper'

describe Booker::V5::Models::ServiceCategory do
  it { is_expected.to be_a Booker::V5::Models::Model }

  it 'has the correct attributes' do
    %w(serviceCategoryId serviceCategoryName services).each do |attr|
      expect(subject).to respond_to(attr)
    end
  end
end
