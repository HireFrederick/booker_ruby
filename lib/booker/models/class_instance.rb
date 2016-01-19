module Booker
  module Models
    class ClassInstance < Model
      attr_accessor 'ID',
        'EndDateTime',
        'HasClassFilled',
        'IsForMembersOnly',
        'IsRecurring',
        'IsSpecialEvent',
        'IsWorkshop',
        'NumReserved',
        'Price',
        'RoomName',
        'StartDateTime',
        'Teacher',
        'Teacher2',
        'TotalCapacity',
        'TreatmentDuration',
        'ListAsSubstitute',
        'IsEnrollable',
        'SeriesID',
        'Treatment'
    end
  end
end
