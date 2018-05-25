require 'spec_helper'

describe Booker::V4::Models::Customer do
  it { is_expected.to be_a Booker::V4::Models::Model }

  it 'has the correct attributes' do
    ['CustomerID',
      'GUID',
      'Address',
      'AllowReceiveEmails',
      'AllowReceivePromotionalEmails',
      'AllowReceiveSMS',
      'CellPhone',
      'CreditCard',
      'Email',
      'FirstName',
      'HasActiveMembership',
      'HomePhone',
      'MobilePhone',
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

  describe '.from_hash' do
    let(:result) { described_class.from_hash(response) }
    context 'when the response is nested' do
      let(:response) { {'CustomerID' => 123, 'Customer' => {'GUID' => 'foo'}} }

      it 'flattens the response' do
        expect(result).to be_a described_class
        expect(result.CustomerID).to eq 123
        expect(result.GUID).to eq 'foo'
      end
    end

    context 'when the response is not nested' do
      let(:response) { {'CustomerID' => 123, 'GUID' => 'foo'} }

      it 'does not flatten the response / simply calls super' do
        expect(result).to be_a described_class
        expect(result.CustomerID).to eq 123
        expect(result.GUID).to eq 'foo'
      end
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
