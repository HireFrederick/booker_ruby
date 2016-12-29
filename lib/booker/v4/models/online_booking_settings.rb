module Booker
  module V4
    module Models
      class OnlineBookingSettings < Model
        attr_accessor 'NewAppointmentCutOffInterval',
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
      end
    end
  end
end
