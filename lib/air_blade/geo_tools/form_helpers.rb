module AirBlade
  module GeoTools
    module FormHelpers

      def latitude_field(method, options = {}, html_options = {})
        text_field("#{method}_degrees", options.merge(
          :id        => "#{@object_name}_#{method}_degrees",
          :name      => "#{@object_name}[#{method}_degrees]",
          :maxlength => 2 )) +
        '&deg;' +

        text_field("#{method}_minutes", options.merge(
          :id        => "#{@object_name}_#{method}_minutes",
          :name      => "#{@object_name}[#{method}_minutes]",
          :maxlength => 2 )) +
        '.' +

        text_field("#{method}_milli_minutes", options.merge(
          :id        => "#{@object_name}_#{method}_milli_minutes",
          :name      => "#{@object_name}[#{method}_milli_minutes]",
          :maxlength => 3 )) +
        '&prime;' +

        # Hmm, we pass the options in the html_options position.
        select("#{method}_hemisphere", %w( N S ), {}, options.merge(
          :id       => "#{@object_name}_#{method}_hemisphere",
          :name     => "#{@object_name}[#{method}_hemisphere]" ))
      end

      def longitude_field(method, options = {}, html_options = {})
        text_field("#{method}_degrees", options.merge(
          :id        => "#{@object_name}_#{method}_degrees",
          :name      => "#{@object_name}[#{method}_degrees]",
          :maxlength => 3 )) +
        '&deg;' +

        text_field("#{method}_minutes", options.merge(
          :id        => "#{@object_name}_#{method}_minutes",
          :name      => "#{@object_name}[#{method}_minutes]",
          :maxlength => 2 )) +
        '.' +

        text_field("#{method}_milli_minutes", options.merge(
          :id        => "#{@object_name}_#{method}_milli_minutes",
          :name      => "#{@object_name}[#{method}_milli_minutes]",
          :maxlength => 3 )) +
        '&prime;' +

        # Hmm, we pass the options in the html_options position.
        select("#{method}_hemisphere", %w( E W ), {}, options.merge(
          :id       => "#{@object_name}_#{method}_hemisphere",
          :name     => "#{@object_name}[#{method}_hemisphere]" ))
      end

      private

    end
  end
end
