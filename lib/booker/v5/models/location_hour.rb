module Booker
  module V5
    module Models
      class LocationHour < Model
        attr_accessor 'open', 'close'

        def self.from_hash(hash)
          model = super
          model.open = Time.parse(model.open) if model.open
          model.close = Time.parse(model.close) if model.close
          model
        end
      end
    end
  end
end
