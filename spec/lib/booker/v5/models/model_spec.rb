require 'spec_helper'

describe Booker::V5::Models::Model do
  it { is_expected.to be_a Booker::Model }
  it { expect(described_class::CONSTANTIZE_MODULE).to be Booker::V5::Models }
end
