require 'test_helper'

class Treasure < ActiveRecord::Base
  acts_as_location
end

class GeoToolsTest < ActiveSupport::TestCase

  context 'A location model' do
    setup { @treasure = Treasure.new }

    should 'convert northern hemisphere latitude fields to a positive float' do
      @treasure.update_attributes location
      assert_in_delta 42.95583, @treasure.latitude, 0.0001
    end

    should 'convert southern hemisphere latitude fields to a negative float' do
      @treasure.update_attributes location(:latitude_hemisphere => 'S')
      assert_in_delta -42.95583, @treasure.latitude, 0.0001
    end

    should 'convert eastern hemisphere longitude fields to a positive float' do
      @treasure.update_attributes location
      assert_in_delta 153.37117, @treasure.longitude, 0.0001
    end

    should 'convert western hemisphere longitude fields to a negative float' do
      @treasure.update_attributes location(:longitude_hemisphere => 'W')
      assert_in_delta -153.37117, @treasure.longitude, 0.0001
    end

    should 'display a pretty #to_s' do
      @treasure.update_attributes location
      assert_equal "42°57.35′N, 153°22.27′E", @treasure.to_s
    end

    teardown { Treasure.destroy_all }
  end

  context 'Location#within' do
    # TODO: use Factory Girl.

    context 'NE quadrant' do
      setup do
        @a = Treasure.create :latitude_degrees => '42', :latitude_hemisphere => 'N', :longitude_degrees => '153', :longitude_hemisphere => 'E', :latitude_minutes => '12', :longitude_minutes => '47'
        @b = Treasure.create :latitude_degrees => '43', :latitude_hemisphere => 'N', :longitude_degrees => '153', :longitude_hemisphere => 'E'
        @c = Treasure.create :latitude_degrees => '42', :latitude_hemisphere => 'N', :longitude_degrees => '154', :longitude_hemisphere => 'E'
      end
      should 'return locations to nearest minute' do
        assert_same_elements [],           Treasure.within(1, 1, 42, 153)
        assert_same_elements [@a, @b, @c], Treasure.within(1, 1, 43, 154)
        assert_same_elements [@c],         Treasure.within(1, 1, f(42, 11), 154)
        assert_same_elements [@a, @c],     Treasure.within(1, 1, f(42, 12), 154)
        assert_same_elements [@b],         Treasure.within(1, 1, 43, f(153, 46))
        assert_same_elements [@a, @b],     Treasure.within(1, 1, 43, f(153, 47))
      end
      teardown { Treasure.destroy_all }
    end

    context 'NW quadrant' do
      setup do
        @a = Treasure.create :latitude_degrees => '42', :latitude_hemisphere => 'N', :longitude_degrees => '153', :longitude_hemisphere => 'W', :latitude_minutes => '12', :longitude_minutes => '47'
        @b = Treasure.create :latitude_degrees => '43', :latitude_hemisphere => 'N', :longitude_degrees => '153', :longitude_hemisphere => 'W'
        @c = Treasure.create :latitude_degrees => '42', :latitude_hemisphere => 'N', :longitude_degrees => '154', :longitude_hemisphere => 'W'
      end
      should 'return locations to nearest minute' do
        assert_same_elements [],           Treasure.within(1, -153, 42, -1)
        assert_same_elements [@a, @b, @c], Treasure.within(1, -154, 43, -1)
        assert_same_elements [@c],         Treasure.within(1, -154, f(42, 11), -1)
        assert_same_elements [@a, @c],     Treasure.within(1, -154, f(42, 12), -1)
        assert_same_elements [@b],         Treasure.within(1, f(-153, 46), 43, -1)
        assert_same_elements [@a, @b],     Treasure.within(1, f(-153, 47), 43, -1)
      end
      teardown { Treasure.destroy_all }
    end

    context 'SE quadrant' do
      setup do
        @a = Treasure.create :latitude_degrees => '42', :latitude_hemisphere => 'S', :longitude_degrees => '153', :longitude_hemisphere => 'E', :latitude_minutes => '12', :longitude_minutes => '47'
        @b = Treasure.create :latitude_degrees => '43', :latitude_hemisphere => 'S', :longitude_degrees => '153', :longitude_hemisphere => 'E'
        @c = Treasure.create :latitude_degrees => '42', :latitude_hemisphere => 'S', :longitude_degrees => '154', :longitude_hemisphere => 'E'
      end
      should 'return locations to nearest minute' do
        assert_same_elements [],           Treasure.within(-42, 1, -1, 153)
        assert_same_elements [@a, @b, @c], Treasure.within(-43, 1, -1, 154)
        assert_same_elements [@c],         Treasure.within(f(-42, 11), 1, -1, 154)
        assert_same_elements [@a, @c],     Treasure.within(f(-42, 12), 1, -1, 154)
        assert_same_elements [@b],         Treasure.within(-43, 1, -1, f(153, 46))
        assert_same_elements [@a, @b],     Treasure.within(-43, 1, -1, f(153, 47))
      end
      teardown { Treasure.destroy_all }
    end

    context 'SW quadrant' do
      setup do
        @a = Treasure.create :latitude_degrees => '42', :latitude_hemisphere => 'S', :longitude_degrees => '153', :longitude_hemisphere => 'W', :latitude_minutes => '12', :longitude_minutes => '47'
        @b = Treasure.create :latitude_degrees => '43', :latitude_hemisphere => 'S', :longitude_degrees => '153', :longitude_hemisphere => 'W'
        @c = Treasure.create :latitude_degrees => '42', :latitude_hemisphere => 'S', :longitude_degrees => '154', :longitude_hemisphere => 'W'
      end
      should 'return locations to nearest minute' do
        assert_same_elements [],           Treasure.within(-42, -153, -1, -1)
        assert_same_elements [@a, @b, @c], Treasure.within(-43, -154, -1, -1)
        assert_same_elements [@c],         Treasure.within(f(-42, 11), -154, -1, -1)
        assert_same_elements [@a, @c],     Treasure.within(f(-42, 12), -154, -1, -1)
        assert_same_elements [@b],         Treasure.within(-43, f(-153, 46), -1, -1)
        assert_same_elements [@a, @b],     Treasure.within(-43, f(-153, 47), -1, -1)
      end
      teardown { Treasure.destroy_all }
    end

    context 'straddling equator and prime meridian' do
      setup do
        @a = Treasure.create :latitude_degrees => '42', :latitude_hemisphere => 'N', :longitude_degrees => '153', :longitude_hemisphere => 'E', :latitude_minutes => '12', :longitude_minutes => '47'
        @b = Treasure.create :latitude_degrees => '42', :latitude_hemisphere => 'N', :longitude_degrees => '153', :longitude_hemisphere => 'W', :latitude_minutes => '12', :longitude_minutes => '47'
        @c = Treasure.create :latitude_degrees => '42', :latitude_hemisphere => 'S', :longitude_degrees => '153', :longitude_hemisphere => 'E', :latitude_minutes => '12', :longitude_minutes => '47'
        @d = Treasure.create :latitude_degrees => '42', :latitude_hemisphere => 'S', :longitude_degrees => '153', :longitude_hemisphere => 'W', :latitude_minutes => '12', :longitude_minutes => '47'
      end
      should 'return locations to nearest degree' do
        assert_same_elements [],               Treasure.within(-42, -153, 42, 153)
        assert_same_elements [@a, @b, @c, @d], Treasure.within(-43, -154, 43, 154)

        assert_same_elements [@a, @b],         Treasure.within(f(-42, 11), -154, 43, 154)
        assert_same_elements [@a, @b, @c, @d], Treasure.within(f(-42, 12), -154, 43, 154)

        assert_same_elements [@a, @c],         Treasure.within(-43, f(-153, 46), 43, 154)
        assert_same_elements [@a, @b, @c, @d], Treasure.within(-43, f(-153, 47), 43, 154)

        assert_same_elements [@c, @d],         Treasure.within(-43, -154, f(42, 11), 154)
        assert_same_elements [@a, @b, @c, @d], Treasure.within(-43, -154, f(42, 12), 154)

        assert_same_elements [@b, @d],         Treasure.within(-43, -154, 43, f(153, 46))
        assert_same_elements [@a, @b, @c, @d], Treasure.within(-43, -154, 43, f(153, 47))
      end
      teardown { Treasure.destroy_all }
    end
  end


  private

  # TODO: use FactoryGirl instead.

  def location(params = {})
    { :latitude_degrees          => 42,
      :latitude_minutes          => 57,
      :latitude_decimal_minutes  => 35,
      :latitude_hemisphere       => 'N',
      :longitude_degrees         => 153,
      :longitude_minutes         => 22,
      :longitude_decimal_minutes => 27,
      :longitude_hemisphere      => 'E' }.merge params
  end

  # Degrees: positive or negative.
  # Minutes: always positive.
  def f(degrees, minutes = 0)
    degrees >= 0 ? degrees + (minutes / 60.0) : degrees - (minutes / 60.0)
  end

end
