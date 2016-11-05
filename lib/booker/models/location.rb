module Booker
  module Models
    class Location < Model
      ACCOUNT_STATUSES = [
        nil,
        'Implementation',
        'Demo',
        'LiveNoCharge',
        'Live',
        'Terminated',
        'ChargeNotLive'
      ].map(&:freeze).freeze

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

      def status_name
        self.Status ? ACCOUNT_STATUSES[self.Status] : nil
      end
    end
  end
end
