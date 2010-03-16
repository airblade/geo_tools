require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the geo_tools plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the geo_tools plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'GeoTools'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = 'geo_tools'
    gemspec.summary = 'View helpers, validations, and named scopes for locations.'
    gemspec.email = 'boss@airbladesoftware.com'
    gemspec.homepage = 'http://github.com/airblade/geo_tools'
    gemspec.authors = ['Andy Stewart']
  end
rescue LoadError
  puts 'Jeweler not available. Install it with: gem install jeweler'
end
