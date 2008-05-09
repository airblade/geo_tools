module AirBlade
  module GeoTools
    module Validations

      def validates_latitude_of(*attr_names)
        validates_degrees_of 'latitude', 90, *attr_names
      end

      def validates_longitude_of(*attr_names)
        validates_degrees_of 'longitude', 180, *attr_names
      end

      private

      def validates_degrees_of(name, maximum, *attr_names)
        configuration = {
          :message => "is not a #{name}",
          :range => -(maximum.abs)..maximum.abs
        }
        configuration.update(attr_names.extract_options!)

        validates_each(attr_names, configuration) do |record, attr_name, value|
          raw_value = record.send("#{attr_name}_before_type_cast") || value
          # Validate attr is a float.
          begin
            raw_value = Kernel.Float(raw_value.to_s)
          rescue ArgumentError, TypeError
            record.errors.add(attr_name, configuration[:message])
            next
          end
          # Validate bounds of attr.
          record.errors.add(attr_name, configuration[:message]) unless configuration[:range].include? raw_value
        end
      end

    end
  end
end
