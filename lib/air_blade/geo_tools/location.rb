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

            # Returns all locations within the given bounding box, to an accuracy of 1 minute.
            #
            # This is useful for finding all locations within the area covered by a Google map.
            #
            # The parameters should be positive/negative floats.
            named_scope :within, lambda { |sw_lat, sw_lng, ne_lat, ne_lng|
              sw_lat_degs = sw_lat.to_i.abs
              sw_lat_mins = ((sw_lat - sw_lat.to_i) * 60.0).round.abs
              ne_lat_degs = ne_lat.to_i.abs
              ne_lat_mins = ((ne_lat - ne_lat.to_i) * 60.0).round.abs

              sw_lng_degs = sw_lng.to_i.abs
              sw_lng_mins = ((sw_lng - sw_lng.to_i) * 60.0).round.abs
              ne_lng_degs = ne_lng.to_i.abs
              ne_lng_mins = ((ne_lng - ne_lng.to_i) * 60.0).round.abs

              # Latitude conditions.
              if sw_lat > 0 && ne_lat > 0       # northern hemisphere
                condition_lat_h  = 'latitude_hemisphere = "N"'
                condition_lat_sw = ["(latitude_degrees > ?) OR (latitude_degrees = ? AND latitude_minutes >= ?)", sw_lat_degs, sw_lat_degs, sw_lat_mins]
                condition_lat_ne = ["(latitude_degrees < ?) OR (latitude_degrees = ? AND latitude_minutes <= ?)", ne_lat_degs, ne_lat_degs, ne_lat_mins]
                condition_lat    = merge_conditions condition_lat_h, condition_lat_sw, condition_lat_ne

              elsif sw_lat < 0 && ne_lat < 0    # southern hemisphere
                condition_lat_h  = 'latitude_hemisphere = "S"'
                condition_lat_sw = ["(latitude_degrees < ?) OR (latitude_degrees = ? AND latitude_minutes <= ?)", sw_lat_degs, sw_lat_degs, sw_lat_mins]
                condition_lat_ne = ["(latitude_degrees > ?) OR (latitude_degrees = ? AND latitude_minutes >= ?)", ne_lat_degs, ne_lat_degs, ne_lat_mins]
                condition_lat    = merge_conditions condition_lat_h, condition_lat_sw, condition_lat_ne

              elsif sw_lat <= 0 && ne_lat >= 0  # straddles equator
                condition_lat_h  = 'latitude_hemisphere = "S"'
                condition_lat_sw = ["(latitude_degrees < ?) OR (latitude_degrees = ? AND latitude_minutes <= ?)", sw_lat_degs, sw_lat_degs, sw_lat_mins]
                condition_lat_s  = merge_conditions condition_lat_h, condition_lat_sw

                condition_lat_h  = 'latitude_hemisphere = "N"'
                condition_lat_ne = ["(latitude_degrees < ?) OR (latitude_degrees = ? AND latitude_minutes <= ?)", ne_lat_degs, ne_lat_degs, ne_lat_mins]
                condition_lat_n  = merge_conditions condition_lat_h, condition_lat_ne

                condition_lat    = merge_or_conditions condition_lat_s, condition_lat_n
              end

              # Longitude conditions.
              if sw_lng > 0 && ne_lng > 0       # eastern hemisphere
                condition_lng_h  = 'longitude_hemisphere = "E"'
                condition_lng_sw = ["(longitude_degrees > ?) OR (longitude_degrees = ? AND longitude_minutes >= ?)", sw_lng_degs, sw_lng_degs, sw_lng_mins]
                condition_lng_ne = ["(longitude_degrees < ?) OR (longitude_degrees = ? AND longitude_minutes <= ?)", ne_lng_degs, ne_lng_degs, ne_lng_mins]
                condition_lng    = merge_conditions condition_lng_h, condition_lng_sw, condition_lng_ne

              elsif sw_lng < 0 && ne_lng < 0    # western hemisphere
                condition_lng_h  = 'longitude_hemisphere = "W"'
                condition_lng_sw = ["(longitude_degrees < ?) OR (longitude_degrees = ? AND longitude_minutes <= ?)", sw_lng_degs, sw_lng_degs, sw_lng_mins]
                condition_lng_ne = ["(longitude_degrees > ?) OR (longitude_degrees = ? AND longitude_minutes >= ?)", ne_lng_degs, ne_lng_degs, ne_lng_mins]
                condition_lng    = merge_conditions condition_lng_h, condition_lng_sw, condition_lng_ne

              elsif sw_lng <= 0 && ne_lng >= 0  # straddles prime meridian
                condition_lng_h  = 'longitude_hemisphere = "W"'
                condition_lng_sw = ["(longitude_degrees < ?) OR (longitude_degrees = ? AND longitude_minutes <= ?)", sw_lng_degs, sw_lng_degs, sw_lng_mins]
                condition_lng_w  = merge_conditions condition_lng_h, condition_lng_sw

                condition_lng_h  = 'longitude_hemisphere = "E"'
                condition_lng_ne = ["(longitude_degrees < ?) OR (longitude_degrees = ? AND longitude_minutes <= ?)", ne_lng_degs, ne_lng_degs, ne_lng_mins]
                condition_lng_e  = merge_conditions condition_lng_h, condition_lng_ne

                condition_lng    = merge_or_conditions condition_lng_w, condition_lng_e
              end

              # Combined latitude and longitude conditions.
              {:conditions => merge_conditions(condition_lat, condition_lng)}
            }

          end
        end
      end

      module ClassMethods
        # Merges conditions so that the result is a valid +condition+.
        # Adapted from ActiveRecord::Base#merge_conditions.
        def merge_or_conditions(*conditions)
          segments = []

          conditions.each do |condition|
            unless condition.blank?
              sql = sanitize_sql(condition)
              segments << sql unless sql.blank?
            end
          end

          "(#{segments.join(') OR (')})" unless segments.empty?
        end
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
