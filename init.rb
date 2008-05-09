ActiveRecord::Base.send :extend, AirBlade::GeoTools::Validations
ActiveRecord::Base.send :include, AirBlade::GeoTools::Location

ActionView::Helpers::FormBuilder.send :include, AirBlade::GeoTools::FormHelpers
