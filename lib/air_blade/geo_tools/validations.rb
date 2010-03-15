module AirBlade
  module GeoTools
    module Validations

      # Sames as validates_numericality_of but additionally supports :for option
      # which lets you attach an error to a different attribute.
      def validates_inclusion_of_for(*attr_names)
        configuration = { :on => :save }
        configuration.update(attr_names.extract_options!)

        enum = configuration[:in] || configuration[:within]

        raise(ArgumentError, "An object with the method include? is required must be supplied as the :in option of the configuration hash") unless enum.respond_to?(:include?)

        validates_each(attr_names, configuration) do |record, attr_name, value|
          unless enum.include?(value)
            attr_for = configuration[:for] || attr_name
            record.errors.add(attr_for, :inclusion, :default => configuration[:message], :value => value) 
          end
        end
      end

      # Sames as validates_numericality_of but additionally supports :for option
      # which lets you attach an error to a different attribute.
      def validates_numericality_of_for(*attr_names)
        configuration = { :on => :save, :only_integer => false, :allow_nil => false }
        configuration.update(attr_names.extract_options!)

        numericality_options = ActiveRecord::Validations::ClassMethods::ALL_NUMERICALITY_CHECKS.keys & configuration.keys

        (numericality_options - [ :odd, :even ]).each do |option|
          raise ArgumentError, ":#{option} must be a number" unless configuration[option].is_a?(Numeric)
        end

        validates_each(attr_names,configuration) do |record, attr_name, value|
          raw_value = record.send("#{attr_name}_before_type_cast") || value

          next if configuration[:allow_nil] and raw_value.nil?

          attr_for = configuration[:for] || attr_name

          if configuration[:only_integer]
            unless raw_value.to_s =~ /\A[+-]?\d+\Z/
              record.errors.add(attr_for, :not_a_number, :value => raw_value, :default => configuration[:message])
              next
            end
            raw_value = raw_value.to_i
          else
            begin
              raw_value = Kernel.Float(raw_value)
            rescue ArgumentError, TypeError
              record.errors.add(attr_for, :not_a_number, :value => raw_value, :default => configuration[:message])
              next
            end
          end

          numericality_options.each do |option|
            case option
            when :odd, :even
              unless raw_value.to_i.method( ActiveRecord::Validations::ClassMethods::ALL_NUMERICALITY_CHECKS[option])[]
                record.errors.add(attr_for, option, :value => raw_value, :default => configuration[:message]) 
              end
            else
              record.errors.add(attr_for, option, :default => configuration[:message], :value => raw_value, :count => configuration[option]) unless raw_value.method( ActiveRecord::Validations::ClassMethods::ALL_NUMERICALITY_CHECKS[option])[configuration[option]]
            end
          end
        end
      end

    end
  end
end


ActiveRecord::Base.send :extend, AirBlade::GeoTools::Validations
