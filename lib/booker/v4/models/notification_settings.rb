module Booker
  module V4
    module Models
      class NotificationSettings < Model
        attr_accessor 'NotificationsEmail',
          'NotifyAdminOnAppointmentOtherEvent',
          'SendAppointmentReminders',
          'SendConfirmationAfterBooking',
          'SendNoticeHoursBeforeAppointment',
          'NotifyServiceProviderOnAppointmentOtherEvent'
      end
    end
  end
end
