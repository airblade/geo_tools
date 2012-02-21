# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "geo_tools/version"

Gem::Specification.new do |s|
  s.name        = 'geo_tools'
  s.version     = GeoTools::VERSION
  s.authors     = ['Andy Stewart']
  s.email       = ['boss@airbladesoftware.com']
  s.homepage    = 'https://github.com/airblade/geo_tools'
  s.summary     = 'Makes using latitudes and longitudes on forms easier.'
  s.description = s.summary

  s.rubyforge_project = 'geo_tools'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'rails', '~> 2.3'

  s.add_development_dependency 'sqlite3-ruby'
  s.add_development_dependency 'shoulda-context', '~> 1.0.0'
end
