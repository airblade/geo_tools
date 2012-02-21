# encoding: utf-8
module GeoTools
  module FormHelpers

    # Options:
    #   :latitude
    #     :degrees
    #       :symbol
    #     :minutes
    #       :symbol
    #     :decimal_minutes
    #       :symbol
    #       :maxlength
    #
    # Assumes the latitude field is called 'latitude'.
    #
    # The 'method' argument is for consistency with other field helpers.  We don't use it
    # when using the normal Rails form builder.
    #
    # 1/100th of a minute of latitude (or equitorial longitude) is approximately 20m.
    def latitude_field(method, options = {})
      opts = {
        :degrees         => { :symbol => '&deg;' },
        :minutes         => { :symbol => '.'     },
        :decimal_minutes => { :symbol => '&prime;', :maxlength => 2 },
      }
      lat_options = options.delete :latitude
      opts.merge! lat_options if lat_options
      
      output = []

      # Degrees
      width = 2
      output << text_field("latitude_degrees",
                           options.merge(:maxlength => width,
                                         :value     => "%0#{width}d" % (@object.send("latitude_degrees") || 0)))
      output << opts[:degrees][:symbol]

      # Minutes
      width = 2
      output << text_field("latitude_minutes",
                           options.merge(:maxlength => width,
                                         :value     => "%0#{width}d" % (@object.send("latitude_minutes") || 0)))
      output << opts[:minutes][:symbol]

      # Decimal minutes
      width = opts[:decimal_minutes][:maxlength]
      output << text_field("latitude_decimal_minutes",
                           options.merge(:maxlength => width,
                                         :value     => @object.send("latitude_decimal_minutes_as_string").ljust(width, '0')))
      output << opts[:decimal_minutes][:symbol]

      # Hemisphere.
      # Hmm, we pass the options in the html_options position.
      output << select("latitude_hemisphere", %w( N S ), {}, options)

      output.join "\n"
    end

    def longitude_field(method, options = {})
      opts = {
        :degrees         => { :symbol => '&deg;' },
        :minutes         => { :symbol => '.'     },
        :decimal_minutes => { :symbol => '&prime;', :maxlength => 2 },
      }
      long_options = options.delete :longitude
      opts.merge! long_options if long_options

      output = []
      
      # Degrees
      width = 3
      output << text_field("longitude_degrees",
                           options.merge(:maxlength => width,
                                         :value     => "%0#{width}d" % (@object.send("longitude_degrees") || 0)))
      output << opts[:degrees][:symbol]

      # Minutes
      width = 2
      output << text_field("longitude_minutes",
                           options.merge(:maxlength => width,
                                         :value     => "%0#{width}d" % (@object.send("longitude_minutes") || 0)))
      output << opts[:minutes][:symbol]

      # Decimal minutes
      width = opts[:decimal_minutes][:maxlength]
      output << text_field("longitude_decimal_minutes",
                           options.merge(:maxlength => width,
                                         :value     => @object.send("longitude_decimal_minutes_as_string").ljust(width, '0')))
      output << opts[:decimal_minutes][:symbol]

      # Hemisphere.
      # Hmm, we pass the options in the html_options position.
      output << select("longitude_hemisphere", %w( E W ), {}, options)

      output.join "\n"
    end

  end
end


ActionView::Helpers::FormBuilder.send :include, GeoTools::FormHelpers
