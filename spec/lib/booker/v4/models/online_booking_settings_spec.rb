require 'spec_helper'

describe Booker::V4::Models::OnlineBookingSettings do
  it { is_expected.to be_a Booker::V4::Models::Model }

  it 'has the correct attributes' do
    [
      'NewAppointmentCutOffInterval',
      'PaymentMethods',
      'PreAuthorizeCreditCard',
      'PreferredAppointmentTimes',
      'RequirePaymentInformation',
      'AppointmentStartTimeInterval',
      'SelectTechnician',
      'SelectTechnicianGender',
      'AllowCancelAppointments',
      'MaximumResultsPerDay',
      'UsePreferredAppointmentTimes',
      'RequireCustomerGender',
      'RequireStreetAddress',
      'GoogleAnalyticsCode',
      'BillingAddressRequired',
      'BackgroundImageUrl',
      'BusinessLogoUrl'
    ].each do |attr|
      expect(subject).to respond_to(attr)
    end
  end
end
