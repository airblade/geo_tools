module AirBlade
  module GeoTools
    module FormHelpers

      def latitude_field(method, options = {}, html_options = {})
        text_field("#{method}_degrees", options.merge(
          :id        => "#{@object_name}_#{method}_degrees",
          :name      => "#{@object_name}[#{method}_degrees]",
          :value     => padded_value("#{method}_degrees", 2),
          :maxlength => 2 )) +
        '&deg;' +

        text_field("#{method}_minutes", options.merge(
          :id        => "#{@object_name}_#{method}_minutes",
          :name      => "#{@object_name}[#{method}_minutes]",
          :value     => padded_value("#{method}_minutes", 2),
          :maxlength => 2 )) +
        '.' +

        text_field("#{method}_milli_minutes", options.merge(
          :id        => "#{@object_name}_#{method}_milli_minutes",
          :name      => "#{@object_name}[#{method}_milli_minutes]",
          :value     => padded_value("#{method}_milli_minutes", 3),
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
          :value     => padded_value("#{method}_degrees", 3),
          :maxlength => 3 )) +
        '&deg;' +

        text_field("#{method}_minutes", options.merge(
          :id        => "#{@object_name}_#{method}_minutes",
          :name      => "#{@object_name}[#{method}_minutes]",
          :value     => padded_value("#{method}_minutes", 2),
          :maxlength => 2 )) +
        '.' +

        text_field("#{method}_milli_minutes", options.merge(
          :id        => "#{@object_name}_#{method}_milli_minutes",
          :name      => "#{@object_name}[#{method}_milli_minutes]",
          :value     => padded_value("#{method}_milli_minutes", 3),
          :maxlength => 3 )) +
        '&prime;' +

        # Hmm, we pass the options in the html_options position.
        select("#{method}_hemisphere", %w( E W ), {}, options.merge(
          :id       => "#{@object_name}_#{method}_hemisphere",
          :name     => "#{@object_name}[#{method}_hemisphere]" ))
      end

      private

      # NOTE: It would be better if we could do this post-processing
      # in the first argument to the text_field method.
      def padded_value(method, width)
        @object.send(method).to_s.rjust(width, '0') if @object
      end

    end
  end
end
