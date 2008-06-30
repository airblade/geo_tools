# NOTE: Perhaps use ActiveRecord's multiparameter assignment instead.
#       Cf ActiveRecord::Base#assign_multiparameter_attributes(pairs),
#          ActiveRecord::Base#execute_callstack_for_multiparameter_attributes(pairs), etc.
module AirBlade
  module GeoTools
    module Location

      def self.included(base)
        # Lazy loading pattern.
        base.extend ActMethods
      end

      module ActMethods
        def acts_as_location
          unless included_modules.include? InstanceMethods
            extend ClassMethods
            include InstanceMethods

            code = <<-END
              before_validation :construct_latitude
              before_validation :construct_longitude

              # Validate value in db.
              validates_latitude_of  :latitude
              validates_longitude_of :longitude
            END
            class_eval code, __FILE__, __LINE__
          end
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        # Validate values from UI.
        # NOTE: potential to clash with model's own validate method.
        def validate
          errors.add :latitude, "degrees are invalid"         if @latitude_degrees_invalid
          errors.add :latitude, "minutes are invalid"         if @latitude_minutes_invalid
          errors.add :latitude, "decimal minutes are invalid" if @latitude_milli_minutes_invalid
          errors.add :latitude, "hemisphere is invalid"       if @latitude_hemisphere_invalid

          errors.add :longitude, "degrees are invalid"         if @longitude_degrees_invalid
          errors.add :longitude, "minutes are invalid"         if @longitude_minutes_invalid
          errors.add :longitude, "decimal minutes are invalid" if @longitude_milli_minutes_invalid
          errors.add :longitude, "hemisphere is invalid"       if @longitude_hemisphere_invalid
        end

        def to_s
          # Unicode degree symbol: C2B0
          # Unicode minute symbol: E280B2
          format = lambda do |degrees, minutes, milli_minutes, hemisphere|
            "#{degrees}\xc2\xb0#{minutes}.#{milli_minutes}\xe2\x80\xb2#{hemisphere}"
          end
          lat = format[latitude_degrees, latitude_minutes, latitude_milli_minutes, latitude_hemisphere]
          long = format[longitude_degrees, longitude_minutes, longitude_milli_minutes, longitude_hemisphere]
          "#{lat}, #{long}"
        end

        attr_writer :latitude_degrees,  :latitude_minutes,  :latitude_milli_minutes,  :latitude_hemisphere
        attr_writer :longitude_degrees, :longitude_minutes, :longitude_milli_minutes, :longitude_hemisphere

        # The pattern for the accessors is:
        # If the user has given a value for the field, return that (held in instance variables).
        # Else if we have an overall latitude or longitude, return the part of it relevant to the field.
        # Else return nil.

        def latitude_degrees
          field_value @latitude_degrees, latitude, lambda { latitude.abs.to_i }, 2, false
        end

        def latitude_minutes
          field_value @latitude_minutes, latitude, lambda { lat_minutes_as_float.to_i }, 2
        end

        def latitude_milli_minutes
          field_value @latitude_milli_minutes, latitude, lambda { ((lat_minutes_as_float - lat_minutes_as_float.to_i) * 1000).to_i }, 3
        end

        def latitude_hemisphere
          field_value @latitude_hemisphere, latitude, lambda { ((latitude > 0) ? 'N' : 'S' ) }
        end


        def longitude_degrees
          field_value @longitude_degrees, longitude, lambda { longitude.abs.to_i }, 3, false
        end

        def longitude_minutes
          field_value @longitude_minutes, longitude, lambda { long_minutes_as_float.to_i }, 2
        end

        def longitude_milli_minutes
          field_value @longitude_milli_minutes, longitude, lambda { ((long_minutes_as_float - long_minutes_as_float.to_i) * 1000).to_i }, 3
        end

        def longitude_hemisphere
          field_value @longitude_hemisphere, longitude, lambda { ((longitude > 0) ? 'E' : 'W' ) }
        end

        private

        # Returns a value for the field.
        # - field holds the value given by the user, if any.
        # - latitude_or_longitude is the current overall value for the latitude or longitude.
        # - current is a lambda which shows the part of the overall latitude or longitude value appropriate for the field.
        # - width is the number of characters for the field.  The field is left-padded with zeros.
        # - pad_if_blank specifies whether or not to pad a blank field with zeros.  We need this option because we default
        # minutes and milli-minutes to zero if they are blank, but not degrees.
        def field_value(field, latitude_or_longitude, current, width = 1, pad_if_blank = true)
          padded = lambda { |x| x.to_s.rjust width, '0' }
          if field
            if field.blank?
              pad_if_blank ? padded[field] : field
            else
              padded[field]
            end
          elsif latitude_or_longitude
            padded[current.call]
          else
            nil
          end
        end

        # Constructs a floating-point latitude from the constituent parts.
        # If they are all blank, we don't bother.
        def construct_latitude
          unless [@latitude_degrees, @latitude_minutes, @latitude_milli_minutes, @latitude_hemisphere].all? { |attr| attr.blank? }
            default_to_zero :@latitude_minutes, :@latitude_milli_minutes
            lat_deg       = to_bounded_float @latitude_degrees,         90, :@latitude_degrees_invalid
            lat_min       = to_bounded_float @latitude_minutes,         59, :@latitude_minutes_invalid
            lat_milli_min = to_bounded_float @latitude_milli_minutes,  999, :@latitude_milli_minutes_invalid
            lat_hem       = to_hemisphere    @latitude_hemisphere, %w(N S), :@latitude_hemisphere_invalid

            unless @latitude_degrees_invalid       || @latitude_minutes_invalid    ||
                   @latitude_milli_minutes_invalid || @latitude_hemisphere_invalid
              self.latitude = coordinates_to_float lat_deg, lat_min, lat_milli_min, lat_hem
            end
          end
        end

        # Constructs a floating-point longitude from the constituent parts.
        # If they are all blank, we don't bother.
        def construct_longitude
          unless [@longitude_degrees, @longitude_minutes, @longitude_milli_minutes, @longitude_hemisphere].all? { |attr| attr.blank? }
            default_to_zero :@longitude_minutes, :@longitude_milli_minutes
            long_deg       = to_bounded_float @longitude_degrees,        180, :@longitude_degrees_invalid
            long_min       = to_bounded_float @longitude_minutes,         59, :@longitude_minutes_invalid
            long_milli_min = to_bounded_float @longitude_milli_minutes,  999, :@longitude_milli_minutes_invalid
            long_hem       = to_hemisphere    @longitude_hemisphere, %w(E W), :@longitude_hemisphere_invalid

            unless @longitude_degrees_invalid       || @longitude_minutes_invalid    ||
                   @longitude_milli_minutes_invalid || @longitude_hemisphere_invalid
              self.longitude = coordinates_to_float long_deg, long_min, long_milli_min, long_hem
            end
          end
        end

        def lat_minutes_as_float
          (latitude.abs - latitude_degrees.to_i) * 60
        end

        def long_minutes_as_float
          (longitude.abs - longitude_degrees.to_i) * 60
        end

        def to_bounded_float(value, maximum, error_flag)
          begin
            value_as_float = Kernel.Float value
            raise ArgumentError if value_as_float > maximum
            value_as_float
          rescue ArgumentError, TypeError
            instance_variable_set error_flag, true
          end
        end

        def to_hemisphere(value, valid_values, error_flag)
          if value =~ /\A(#{valid_values.join('|')})\Z/i
            value_as_hemisphere = value.upcase
          else
            instance_variable_set error_flag, true
          end
        end

        def coordinates_to_float(degrees, minutes, milli_minutes, hemisphere)
          f = degrees + ( (minutes + (milli_minutes / 1000)) / 60 )
          f = f * -1 if hemisphere == 'S' || hemisphere == 'W'
          f
        end

        def default_to_zero(*fields)
          fields.each do |field|
            instance_variable_set field, 0 if instance_variable_get(field).blank? || instance_variable_get(field).to_s == '0'
          end
        end

      end
    end
  end
end
