require 'spec_helper'

describe Booker::V4::Models::Location do
  it { is_expected.to be_a Booker::V4::Models::Model }

  it 'has the correct attributes' do
    [
      'ID',
      'AccountName',
      'BusinessName',
      'BusinessType',
      'EmailAddress',
      'Address',
      'Phone',
      'TimeZone',
      'WebSite',
      'IsDistributionPartner',
      'EncryptedLocationID',
      'BrandAccountName',
      'LogoUrl',
      'BusinessType',
      'FirstName',
      'LastName',
      'CurrencyCode',
      'Status'
    ].each do |attr|
      expect(subject).to respond_to(attr)
      expect(subject).to respond_to("#{attr}=")
    end
  end

  it '#status_name' do
    [
      nil,
     'Implementation',
     'Demo',
     'LiveNoCharge',
     'Live',
     'Terminated',
     'ChargeNotLive'
    ].each_with_index do |status, i|
      subject.Status = i
      expect(subject.status_name).to eq status
    end
  end
end
