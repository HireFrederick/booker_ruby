require 'spec_helper'

describe Booker::Models::NotificationSettings do
  it 'has the correct attributes' do
    ['NotificationsEmail',
      'NotifyAdminOnAppointmentOtherEvent',
      'SendAppointmentReminders',
      'SendConfirmationAfterBooking',
      'SendNoticeHoursBeforeAppointment',
      'NotifyServiceProviderOnAppointmentOtherEvent'].each do |attr|
      expect(subject).to respond_to(attr)
    end
  end
end
