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
        Treasure.create :latitude_degrees => '42', :latitude_hemisphere => 'N', :longitude_degrees => '153', :longitude_hemisphere => 'E'
        Treasure.create :latitude_degrees => '43', :latitude_hemisphere => 'N', :longitude_degrees => '153', :longitude_hemisphere => 'E'
        Treasure.create :latitude_degrees => '42', :latitude_hemisphere => 'N', :longitude_degrees => '154', :longitude_hemisphere => 'E'
      end
      should 'return locations to nearest degree' do
        assert_equal 1, Treasure.within(0, 0, 42, 153).length
        assert_equal 2, Treasure.within(0, 0, 43, 153).length
        assert_equal 2, Treasure.within(0, 0, 42, 154).length
      end
      teardown { Treasure.destroy_all }
    end

    context 'NW quadrant' do
      setup do
        Treasure.create :latitude_degrees => '42', :latitude_hemisphere => 'N', :longitude_degrees => '153', :longitude_hemisphere => 'W'
        Treasure.create :latitude_degrees => '43', :latitude_hemisphere => 'N', :longitude_degrees => '153', :longitude_hemisphere => 'W'
        Treasure.create :latitude_degrees => '42', :latitude_hemisphere => 'N', :longitude_degrees => '154', :longitude_hemisphere => 'W'
      end
      should 'return locations to nearest degree' do
        assert_equal 1, Treasure.within(0, -153, 42, 0).length
        assert_equal 2, Treasure.within(0, -154, 42, 0).length
        assert_equal 2, Treasure.within(0, -153, 43, 0).length
      end
      teardown { Treasure.destroy_all }
    end

    context 'SE quadrant' do
      setup do
        Treasure.create :latitude_degrees => '42', :latitude_hemisphere => 'S', :longitude_degrees => '153', :longitude_hemisphere => 'E'
        Treasure.create :latitude_degrees => '43', :latitude_hemisphere => 'S', :longitude_degrees => '153', :longitude_hemisphere => 'E'
        Treasure.create :latitude_degrees => '42', :latitude_hemisphere => 'S', :longitude_degrees => '154', :longitude_hemisphere => 'E'
      end
      should 'return locations to nearest degree' do
        assert_equal 1, Treasure.within(-42, 0, 0, 153).length
        assert_equal 2, Treasure.within(-43, 0, 0, 153).length
        assert_equal 2, Treasure.within(-42, 0, 0, 154).length
      end
      teardown { Treasure.destroy_all }
    end

    context 'SW quadrant' do
      setup do
        Treasure.create :latitude_degrees => '42', :latitude_hemisphere => 'S', :longitude_degrees => '153', :longitude_hemisphere => 'W'
        Treasure.create :latitude_degrees => '43', :latitude_hemisphere => 'S', :longitude_degrees => '153', :longitude_hemisphere => 'W'
        Treasure.create :latitude_degrees => '42', :latitude_hemisphere => 'S', :longitude_degrees => '154', :longitude_hemisphere => 'W'
      end
      should 'return locations to nearest degree' do
        assert_equal 1, Treasure.within(-42, -153, 0, 0).length
        assert_equal 2, Treasure.within(-42, -154, 0, 0).length
        assert_equal 2, Treasure.within(-43, -153, 0, 0).length
      end
      teardown { Treasure.destroy_all }
    end

    context 'straddling equator and prime meridian' do
      setup do
        Treasure.create :latitude_degrees => '42', :latitude_hemisphere => 'N', :longitude_degrees => '153', :longitude_hemisphere => 'E'
        Treasure.create :latitude_degrees => '42', :latitude_hemisphere => 'N', :longitude_degrees => '153', :longitude_hemisphere => 'W'
        Treasure.create :latitude_degrees => '42', :latitude_hemisphere => 'S', :longitude_degrees => '153', :longitude_hemisphere => 'E'
        Treasure.create :latitude_degrees => '42', :latitude_hemisphere => 'S', :longitude_degrees => '153', :longitude_hemisphere => 'W'
      end
      should 'return locations to nearest degree' do
        assert_equal 4, Treasure.within(-42, -153, 42, 153).length
        assert_equal 2, Treasure.within(-41, -153, 42, 153).length
        assert_equal 2, Treasure.within(-42, -152, 42, 153).length
        assert_equal 2, Treasure.within(-42, -153, 41, 153).length
        assert_equal 2, Treasure.within(-42, -153, 42, 152).length
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

end
