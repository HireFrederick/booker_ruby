module Booker
  module Models
    class Country < Type
      # ISO 3166-1 alpha-2 Codes
      NAMES_TO_ISO_CODES = YAML::load_file(File.join(__dir__, '..', 'config', 'booker_country_names_to_iso_codes.yml')).freeze

      def country_code; NAMES_TO_ISO_CODES[self.Name]; end
    end
  end
end
