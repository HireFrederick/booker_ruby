require 'spec_helper'

describe Booker::Models::Location do
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
end
