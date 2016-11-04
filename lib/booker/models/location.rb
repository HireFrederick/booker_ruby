module Booker
  module Models
    class Location < Model
      attr_accessor 'ID',
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
    end
  end
end
