module Booker
  class Model
    CONSTANTIZE_MODULE = Booker

    def initialize(options = {})
      @attributes = []
      options.each do |k, v|
        send(:"#{k}=", v)
        @attributes << k.to_sym
      end
    end

    def to_hash
      hash = {}
      @attributes.each do |attr|
        value = self.send(attr)
        if value.is_a? Array
          new_value = hash_list(value)
        elsif value.is_a? Booker::Model
          new_value = value.to_hash
        elsif value.is_a? Time
          new_value = self.class.try(:time_to_booker_datetime, value) || value
        elsif value.is_a? Date
          time = value.in_time_zone
          new_value = self.class.try(:time_to_booker_datetime, time) || value
        else
          new_value = value
        end
        hash[attr] = new_value
      end
      hash
    end

    def self.from_hash(hash)
      model = self.new
      hash.each do |k, v|
        if model.respond_to?(:"#{k}")
          constantized = self.constantize(k)
          if constantized
            if v.is_a?(Array) && v.first.is_a?(Hash)
              model.send(:"#{k}=", constantized.from_list(v))
              next
            elsif v.is_a? Hash
              model.send(:"#{k}=", constantized.from_hash(v))
              next
            end
          end
          if v.is_a?(String) && v.start_with?('/Date(')
            model.send(:"#{k}=", try(:time_from_booker_datetime, v) || v)
            next
          end
          model.send(:"#{k}=", v)
        end
      end
      model
    end

    def to_json; Oj.dump(to_hash, mode: :compat); end

    def self.from_list(array); array.map { |item| self.from_hash(item) }; end

    def self.constantize(key)
      begin
        self::CONSTANTIZE_MODULE.const_get key.to_s.camelize.singularize
      rescue NameError
        nil
      end
    end

    private

    def hash_list(array)
      array.map do |item|
        if item.is_a? Array
          hash_list(item)
        elsif item.is_a? Booker::Model
          item.to_hash
        else
          item
        end
      end
    end
  end
end
