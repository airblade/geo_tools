module AirBlade
  module GeoTools

    # Assumes latitudes are stored as floats between -90 and +90.
    def validates_latitude_of(*attr_names)
      validates_degrees_of 'latitude', 90, *attr_names
    end

    # Assumes longitudes are stored as floats between -180 and +180.
    def validates_longitude_of(*attr_names)
      validates_degrees_of 'longitude', 180, *attr_names
    end

    private

    def validates_degrees_of(name, maximum, *attr_names)
      configuration = { :on => :save, :allow_nil => false }
      configuration.update(attr_names.extract_options!)

      validates_each(attr_names, configuration) do |record, attr_name, value|
        validates_numericality_of attr_name,
                                  :greater_than_or_equal_to => -(maximum.abs),
                                  :less_than_or_equal_to => maximum.abs,
                                  :message => (configuration[:message] || "is not a #{name}"),
                                  :allow_nil => configuration[:allow_nil]
      end

    end
  end
end
