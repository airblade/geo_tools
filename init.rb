ActiveRecord::Base.send :extend,  AirBlade::GeoTools::Validations
ActiveRecord::Base.send :include, AirBlade::GeoTools::Location

# Integrate with standard Rails form builder.
ActionView::Helpers::FormBuilder.send :include, AirBlade::GeoTools::FormHelpers

# Integrate with custom AirBudd form builder.
if defined?(AirBlade::GeoTools::FormHelpers)
  AirBlade::AirBudd::FormBuilder.send :include, AirBlade::GeoTools::AirBuddFormHelpers
end
