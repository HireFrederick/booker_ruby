module Booker
  module V4
    module Models
      class Customer < Model
        attr_accessor 'CustomerID',
                      'GUID',
                      'Address',
                      'AllowReceiveEmails',
                      'AllowReceiveSMS',
                      'SendEmail',
                      'CellPhone', # Returned when using FindCustomers
                      'CreditCard',
                      'Email',
                      'FirstName',
                      'HasActiveMembership',
                      'HomePhone',
                      'MobilePhone', # Set this when making an appointment
                      'MobilePhoneCarrierID',
                      'LastName',
                      'WorkPhone',
                      'WorkPhoneExt',
                      'ShippingAddress',
                      'CustomerRecordType',
                      'DateOfBirth',
                      'Gender',
                      'GenderID',
                      'HasMembership',
                      'HasPastMembership',
                      'IsNewCustomer',
                      'LoyaltyPoints',
                      'LocationID',
                      'LocationName',
                      'NumberOfReferrals',
                      'PreferredStaffGender',
                      'EmergencyContactName',
                      'EmergencyContactPhone',
                      'EmergencyContactRelationship',
                      'IsActive',
                      'Occupation',
                      'PreferredStaffMemberID',
                      'ReferredByCustomerID'

        def self.from_list(array)
          if array.any? && array.first['Customer']
            flattened = array.map{|a| a['Customer'].merge('CustomerID' => a['CustomerID'])}
            super(flattened)
          else
            super
          end
        end
      end
    end
  end
end
