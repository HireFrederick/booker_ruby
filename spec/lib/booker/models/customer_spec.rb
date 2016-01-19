require 'spec_helper'

describe Booker::Models::Customer do
  it 'has the correct attributes' do
    ['CustomerID',
      'GUID',
      'Address',
      'AllowReceiveEmails',
      'AllowReceiveSMS',
      'CellPhone',
      'CreditCard',
      'Email',
      'FirstName',
      'HasActiveMembership',
      'HomePhone',
      'MobilePhone',
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
      'SendEmail',
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
      'ReferredByCustomerID'].each do |attr|
        expect(subject).to respond_to(attr)
    end
  end

  describe '.from_list' do
    let(:result) { described_class.from_list(response) }
    context 'when the response is nested' do
      let(:response) { ['CustomerID' => 123, 'Customer' => {'GUID' => 'foo'}] }

      it 'flattens the response' do
        expect(result.length).to be 1
        expect(result.first).to be_a described_class
        expect(result.first.CustomerID).to eq 123
        expect(result.first.GUID).to eq 'foo'
      end
    end

    context 'when the response is not nested' do
      let(:response) { ['CustomerID' => 123, 'GUID' => 'foo'] }

      it 'does not flatten the response / simply calls super' do
        expect(result.length).to be 1
        expect(result.first).to be_a described_class
        expect(result.first.CustomerID).to eq 123
        expect(result.first.GUID).to eq 'foo'
      end
    end
  end
end
