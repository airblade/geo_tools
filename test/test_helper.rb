require 'test/unit'
require 'shoulda-context'

require 'active_record'
require 'action_view'
require 'active_support'
require 'active_support/test_case'


ActiveRecord::Base.establish_connection(
  :adapter  => "sqlite3",
  :database => ":memory:"
)
load File.dirname(__FILE__) + '/schema.rb'

class ActiveSupport::TestCase
  # FIXME: why won't this work?
  #self.use_transactional_fixtures = true
end

class Test::Unit::TestCase

  # Asserts that two arrays contain the same elements, the same number of times. Essentially ==, but unordered.
  def assert_same_elements(a1, a2, msg=nil)
    [:select, :inject, :size].each do |m|
      [a1, a2].each {|a| assert_respond_to(a, m, "Are you sure that #{a.inspect} is an array?  It doesn't respond to #{m}.") }
    end

    assert a1h = a1.inject({}) { |h,e| h[e] = a1.select { |i| i == e }.size; h }
    assert a2h = a2.inject({}) { |h,e| h[e] = a2.select { |i| i == e }.size; h }

    assert_equal(a1h, a2h, msg)
  end

end
