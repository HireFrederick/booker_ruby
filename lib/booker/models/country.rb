module Booker
  module Models
    class Country < Type
      NAMES_TO_CODES = YAML::load_file(File.join(__dir__, '..', 'config', 'booker_countries.yml')).freeze

      def country_code; NAMES_TO_CODES[self.Name]; end
    end
  end
end
