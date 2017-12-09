module Nylas
  module Model
    class Attributes
      class UndefinedAttributeError < StandardError
        def initialize(attribute, attribute_list)
          super("#{attribute} not in #{attribute_list}")
        end
      end
      attr_accessor :data, :attribute_definitions

      def initialize(attribute_definitions)
        @attribute_definitions = attribute_definitions
        @data = Registry.new(default_attributes)
      end

      def [](key)
        data[key]
      end

      def []=(key, value)
        data[key] = cast(key, value)
      end

      private def cast(key, value)
        attribute_definitions[key].cast(value)
      end

      # Merges data into the registry while casting input types correctly
      def merge(new_data)
        new_data.each do |attribute_name, value|
          self[attribute_name] = value
        end
      end

      def to_h(keys: attribute_definitions.keys)
        keys.each_with_object({}) do |key, casted_data|
          value = attribute_definitions[key].serialize(self[key])
          casted_data[key] = value unless value.nil? || value.empty?
        end
      end

      def serialize(keys: attribute_definitions.keys)
        JSON.dump(to_h(keys: keys))
      end

      private def default_attributes
        attribute_definitions.keys.zip([]).to_h
      end
    end
  end
end
