require 'rubygems'
require 'test/unit'
require 'shoulda'

require 'active_record'
require 'action_view'

require 'lib/geo_tools'

ActiveRecord::Base.establish_connection(
  :adapter  => "sqlite3",
  :database => ":memory:"
)
load File.dirname(__FILE__) + '/schema.rb'
