module AirBlade
  module GeoTools
    module FormHelpers

      def latitude_field(method, options = {}, html_options = {})
        text_field("#{method}_degrees",       options.merge(:maxlength => 2)) + '&deg;'   +
        text_field("#{method}_minutes",       options.merge(:maxlength => 2)) + '.'       +
        text_field("#{method}_milli_minutes", options.merge(:maxlength => 3)) + '&prime;' +
        # Hmm, we pass the options in the html_options position.
        select("#{method}_hemisphere", %w( N S ), {}, options)
      end

      def longitude_field(method, options = {}, html_options = {})
        text_field("#{method}_degrees",       options.merge(:maxlength => 3)) + '&deg;'   +
        text_field("#{method}_minutes",       options.merge(:maxlength => 2)) + '.'       +
        text_field("#{method}_milli_minutes", options.merge(:maxlength => 3)) + '&prime;' +
        # Hmm, we pass the options in the html_options position.
        select("#{method}_hemisphere", %w( E W ), {}, options)
      end

    end
  end
end
