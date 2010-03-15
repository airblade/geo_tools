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
              validates_numericality_of_for :latitude_degrees,
                                            :only_integer             => true,
                                            :greater_than_or_equal_to => 0,
                                            :less_than_or_equal_to    => 90,
                                            :message                  => 'Degrees are invalid',
                                            :for                      => :latitude

              validates_numericality_of_for :latitude_minutes,
                                            :only_integer             => true,
                                            :greater_than_or_equal_to => 0,
                                            :less_than                => 60,
                                            :message                  => 'Minutes are invalid',
                                            :for                      => :latitude

              validates_numericality_of_for :latitude_decimal_minutes,
                                            :only_integer              => true,
                                            :greater_than_or_equal_to  => 0,
                                            :message                   => 'Decimal minutes are invalid',
                                            :for                       => :latitude

              validates_numericality_of_for :latitude_decimal_minutes_width,
                                            :only_integer             => true,
                                            :greater_than_or_equal_to => 0,
                                            :for                      => :latitude

              validates_inclusion_of_for    :latitude_hemisphere,
                                            :in      => %w( N S ),
                                            :message => 'Hemisphere is invalid',
                                            :for     => :latitude

              validates_numericality_of_for :longitude_degrees,
                                            :only_integer             => true,
                                            :greater_than_or_equal_to => 0,
                                            :less_than_or_equal_to    => 180,
                                            :message                  => 'Degrees are invalid',
                                            :for                      => :longitude

              validates_numericality_of_for :longitude_minutes,
                                            :only_integer             => true,
                                            :greater_than_or_equal_to => 0,
                                            :less_than                => 60,
                                            :message                  => 'Minutes are invalid',
                                            :for                      => :longitude

              validates_numericality_of_for :longitude_decimal_minutes,
                                            :only_integer             => true,
                                            :greater_than_or_equal_to => 0,
                                            :message                  => 'Decimal minutes are invalid',
                                            :for                      => :longitude

              validates_numericality_of_for :longitude_decimal_minutes_width,
                                            :only_integer             => true,
                                            :greater_than_or_equal_to => 0,
                                            :for                      => :longitude

              validates_inclusion_of_for    :longitude_hemisphere,
                                            :in      => %w( E W ),
                                            :message => 'Hemisphere is invalid',
                                            :for     => :longitude

              before_validation :set_empty_values
            END
            class_eval code, __FILE__, __LINE__

            # Returns all locations within (to a degree) the given bounding box.
            #
            # This is useful for finding all locations within the area covered by a Google map.
            #
            # The parameters should be positive/negative floats.
            named_scope :within, lambda { |_sw_lat, _sw_lng, _ne_lat, _ne_lng|
              # Nearest degree is precise enough and makes the SQL much simpler.
              sw_lat, sw_lng, ne_lat, ne_lng = _sw_lat.round, _sw_lng.round, _ne_lat.round, _ne_lng.round

              # Latitude conditions.
              if sw_lat > 0 && ne_lat > 0     # northern hemisphere
                condition_lat = ["latitude_degrees > ? AND latitude_degrees < ? AND latitude_hemisphere = 'N'", sw_lat, ne_lat]
              elsif sw_lat < 0 && ne_lat < 0  # southern hemisphere
                condition_lat = ["latitude_degrees < ? AND latitude_degrees > ? AND latitude_hemisphere = 'S'", sw_lat.abs, ne_lat.abs]
              elsif sw_lat <= 0 && ne_lat >= 0  # straddles equator
                condition_lat = ["(latitude_degrees <= ? AND latitude_hemisphere = 'S') OR (latitude_degrees <= ? AND latitude_hemisphere = 'N')", sw_lat.abs, ne_lat]
              end

              # Longitude conditions.
              if sw_lng > 0 && ne_lng > 0     # eastern hemisphere
                condition_lng = ["longitude_degrees > ? AND longitude_degrees < ? AND longitude_hemisphere = 'E'", sw_lng, ne_lng]
              elsif sw_lng < 0 && ne_lng < 0  # western hemisphere
                condition_lng = ["longitude_degrees < ? AND longitude_degrees > ? AND longitude_hemisphere = 'W'", sw_lng.abs, ne_lng.abs]
              elsif sw_lng <= 0 && ne_lng >= 0  # straddles prime meridian
                condition_lng = ["(longitude_degrees <= ? AND longitude_hemisphere = 'W') OR (longitude_degrees <= ? AND longitude_hemisphere = 'E')", sw_lng.abs, ne_lng]
              end

              # Combined latitude and longitude conditions.
              {:conditions => merge_conditions(condition_lat, condition_lng)}
            }

          end
        end
      end

      module ClassMethods
      end

      module InstanceMethods

        def latitude_decimal_minutes=(value)
          unless value.nil?
            width = value.to_s.length
            value = value.to_i

            write_attribute :latitude_decimal_minutes, value
            write_attribute :latitude_decimal_minutes_width, width
          end
        end

        def latitude_decimal_minutes_as_string
          "%0#{latitude_decimal_minutes_width}d" % latitude_decimal_minutes
        end

        def longitude_decimal_minutes=(value)
          unless value.nil?
            width = value.to_s.length
            value = value.to_i

            write_attribute :longitude_decimal_minutes, value
            write_attribute :longitude_decimal_minutes_width, width
          end
        end

        def longitude_decimal_minutes_as_string
          "%0#{longitude_decimal_minutes_width}d" % longitude_decimal_minutes
        end

        def latitude
          to_float latitude_degrees, latitude_minutes, latitude_decimal_minutes,
                   latitude_decimal_minutes_width, latitude_hemisphere
        end

        def longitude
          to_float longitude_degrees, longitude_minutes, longitude_decimal_minutes,
                   longitude_decimal_minutes_width, longitude_hemisphere
        end

        def to_s
          # Unicode degree symbol, full stop, Unicode minute symbol.
          units = [ "\xc2\xb0", '.',  "\xe2\x80\xb2" ]

          lat_fields = ["%02d" % latitude_degrees,
                        "%02d" % latitude_minutes,
                        latitude_decimal_minutes_as_string.ljust(2, '0'),
                        latitude_hemisphere]
          lat = lat_fields.zip(units).map{ |f| f.join }.join

          long_fields = ["%02d" % longitude_degrees,
                         "%02d" % longitude_minutes,
                         longitude_decimal_minutes_as_string.ljust(2, '0'),
                         longitude_hemisphere]
          long = long_fields.zip(units).map{ |f| f.join }.join

          "#{lat}, #{long}"
        end

        private

        def to_float(degrees, minutes, decimal_minutes, decimal_minutes_width, hemisphere)
          return nil if degrees.nil? and minutes.nil? and decimal_minutes.nil?
          degrees ||= 0
          minutes ||= 0
          decimal_minutes ||= 0

          f = degrees.to_f
          f = f + (minutes.to_f + decimal_minutes.to_f / 10 ** decimal_minutes_width) / 60.0
          f = f * -1 if hemisphere == 'S' or hemisphere == 'W'
          f
        end

        # If some of the fields are empty, set them to zero.  This is to speed up data entry.
        # If all the fields are empty, leave them empty.
        def set_empty_values
          unless latitude_degrees.blank? and latitude_minutes.blank? and latitude_decimal_minutes.blank?
            self.latitude_degrees = 0         if latitude_degrees.blank?
            self.latitude_minutes = 0         if latitude_minutes.blank?
            self.latitude_decimal_minutes = 0 if latitude_decimal_minutes.blank?
          end

          unless longitude_degrees.blank? and longitude_minutes.blank? and longitude_decimal_minutes.blank?
            self.longitude_degrees = 0         if longitude_degrees.blank?
            self.longitude_minutes = 0         if longitude_minutes.blank?
            self.longitude_decimal_minutes = 0 if longitude_decimal_minutes.blank?
          end
        end
      end

    end
  end
end


ActiveRecord::Base.send :include, AirBlade::GeoTools::Location
