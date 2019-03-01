module Booker
  module V4
    module Models
      class Model < Booker::Model
        extend ::Booker::Concerns::DateTimeConcern

        CONSTANTIZE_MODULE = Booker::V4::Models

      end
    end
  end
end
