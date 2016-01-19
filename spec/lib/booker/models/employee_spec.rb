require 'spec_helper'

describe Booker::Models::Employee do
  it 'has the correct attributes' do
    ['ID', 'FirstName', 'LastName', 'Gender'].each do |attr|
      expect(subject).to respond_to(attr)
    end
  end
end
