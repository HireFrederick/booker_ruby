require 'spec_helper'

describe Booker::Models::OnlineBookingSettings do
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
