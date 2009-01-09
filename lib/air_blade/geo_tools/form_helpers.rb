module AirBlade
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
        output << plain_text_field("latitude_degrees",
                             options.merge(:maxlength => width,
                                           :value     => "%0#{width}d" % @object.send("latitude_degrees")))
        output << opts[:degrees][:symbol]

        # Minutes
        width = 2
        output << plain_text_field("latitude_minutes",
                             options.merge(:maxlength => width,
                                           :value     => "%0#{width}d" % @object.send("latitude_minutes")))
        output << opts[:minutes][:symbol]

        # Decimal minutes
        width = opts[:decimal_minutes][:maxlength]
        output << plain_text_field("latitude_decimal_minutes",
                             options.merge(:maxlength => width,
                                           :value     => "%0#{width}d" % @object.send("latitude_decimal_minutes")))
        output << opts[:decimal_minutes][:symbol]

        # Hemisphere.
        # Hmm, we pass the options in the html_options position.
        output << plain_select("latitude_hemisphere", %w( N S ), {}, options)

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
        output << plain_text_field("longitude_degrees",
                             options.merge(:maxlength => width,
                                           :value     => "%0#{width}d" % @object.send("longitude_degrees")))
        output << opts[:degrees][:symbol]

        # Minutes
        width = 2
        output << plain_text_field("longitude_minutes",
                             options.merge(:maxlength => width,
                                           :value     => "%0#{width}d" % @object.send("longitude_minutes")))
        output << opts[:minutes][:symbol]

        # Decimal minutes
        width = opts[:decimal_minutes][:maxlength]
        output << plain_text_field("longitude_decimal_minutes",
                             options.merge(:maxlength => width,
                                           :value     => "%0#{width}d" % @object.send("longitude_decimal_minutes")))
        output << opts[:decimal_minutes][:symbol]

        # Hemisphere.
        # Hmm, we pass the options in the html_options position.
        output << plain_select("longitude_hemisphere", %w( E W ), {}, options)

        output.join "\n"
      end

      # A layer of indirection to allow us always to use a plain field helpers,
      # regardless of the form builder being used.

      def plain_text_field(*a, &b)
        text_field(*a, &b)
      end

      def plain_select(*a, &b)
        select(*a, &b)
      end
    end


    module AirBuddFormHelpers
      include AirBlade::GeoTools::FormHelpers
      alias_method :plain_latitude_field,  :latitude_field
      alias_method :plain_longitude_field, :longitude_field

      # Override latitude_field to wrap it with the custom form builder gubbins.
      # http://github.com/airblade/air_budd_form_builder/tree/master/lib/air_blade/air_budd/form_builder.rb
      def latitude_field(method, options = {}, html_options = {})
        @template.content_tag('p',
          label_element(method, options, html_options) +
          (
            plain_latitude_field method, options
          ) +
          hint_element(options),
          (errors_for?(method) ? {:class => 'error'} : {})
        )
      end

      # Override longitude_field to wrap it with the custom form builder gubbins.
      # http://github.com/airblade/air_budd_form_builder/tree/master/lib/air_blade/air_budd/form_builder.rb
      def longitude_field(method, options = {}, html_options = {})
        @template.content_tag('p',
          label_element(method, options, html_options) +
          (
            plain_longitude_field method, options
          ) +
          hint_element(options),
          (errors_for?(method) ? {:class => 'error'} : {})
        )
      end

      # Use the standard Rails helpers for text fields and selects.
      # These are overridden by the AirBudd form builder, so we define
      # them ourselves.

      def plain_text_field(method, options = {})
        # From ActionView::Helpers::FormBuilder
        @template.send('text_field', @object_name, method, objectify_options(options))
      end
      def plain_select(method, choices, options = {}, html_options = {})
        # From ActionView::Helpers::FormOptionsHelper::FormBuilder
        @template.select(@object_name, method, choices, objectify_options(options), @default_options.merge(html_options))
      end
    end

  end
end
