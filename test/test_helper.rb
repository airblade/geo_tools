require 'rubygems'

require 'test/unit'
require 'shoulda'

require 'active_record'
require 'action_view'
require 'active_support'
require 'active_support/test_case'

require 'lib/geo_tools'

ActiveRecord::Base.establish_connection(
  :adapter  => "sqlite3",
  :database => ":memory:"
)
load File.dirname(__FILE__) + '/schema.rb'

class ActiveSupport::TestCase
  # FIXME: why won't this work?
  #self.use_transactional_fixtures = true
end
