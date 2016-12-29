module Booker
  module V5
    module Models
      class Availability < Model
        attr_accessor 'startDateTime',
          'endDateTime',
          'employees'

        def self.from_hash(hash)
          model = super
          model.startDateTime = Time.parse(model.startDateTime) if model.startDateTime
          model.endDateTime = Time.parse(model.endDateTime) if model.endDateTime
          model
        end
      end
    end
  end
end
