require 'spec_helper'

describe Booker::V4::Models::Employee do
  it { is_expected.to be_a Booker::V4::Models::Model }

  it 'has the correct attributes' do
    ['ID', 'FirstName', 'LastName', 'Gender'].each do |attr|
      expect(subject).to respond_to(attr)
    end
  end
end
