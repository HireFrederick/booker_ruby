module Booker
  module Models
    class Country < Type
      # ISO 3166-1 alpha-2 Codes
      IDS_TO_ISO_CODES = YAML::load_file(File.join(__dir__, '..', 'config', 'booker_country_ids_to_iso_codes.yml')).freeze

      def country_code; IDS_TO_ISO_CODES[self.ID]; end
    end
  end
end
