require 'spec_helper'

describe Booker::Models::AppointmentTreatment do
  it 'has the correct attributes' do
    ['AppointmentID',
      'DynamicPrice',
      'EndDateTime',
      'ID',
      'StartDateTime',
      'ChildID',
      'ChildName',
      'AllowChangeStartTime',
      'DynamicPriceID',
      'Employee',
      'Employee2FullName',
      'Employee2ID',
      'EmployeeFirstName',
      'EmployeeFullName',
      'EmployeeID',
      'EmployeeLastName',
      'EmployeeRecoveryDuration',
      'EmployeeTypeID',
      'EmployeeWasRequested',
      'FinishStartDateTime',
      'FinishTimeAppliedToEmployee',
      'FinishTimeAppliedToRoom',
      'FinishTimeDuration',
      'FinishTimeOriginalDuration',
      'ProcessingStartDateTime',
      'ProcessingTimeAppliedToRoom',
      'ProcessingTimeAppliedToEmployee',
      'ProcessingTimeDuration',
      'ProcessingTimeOriginalDuration',
      'RequiresProcessingTime',
      'Room',
      'RoomID',
      'RoomName',
      'RoomRecoveryDuration',
      'StartTimeDuration',
      'StartTimeOriginalDuration',
      'TagPrice',
      'Treatment',
      'TreatmentDuration',
      'TreatmentID',
      'TreatmentIsForCouples',
      'TreatmentName',
      'ClassInstanceID',
      'IsDurationOverridden'].each do |attr|
      expect(subject).to respond_to(attr)
      expect(subject).to respond_to("#{attr}=")
    end
  end
end
