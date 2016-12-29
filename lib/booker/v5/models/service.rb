module Booker
  module V5
    module Models
      class Service < Model
        attr_accessor 'serviceId',
          'serviceName',
          'duration',
          'requiresStaff',
          'availability'
      end
    end
  end
end
