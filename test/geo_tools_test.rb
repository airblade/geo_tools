require 'test_helper'

class Treasure < ActiveRecord::Base
  acts_as_location
end

class GeoToolsTest < Test::Unit::TestCase

  context 'A location model' do
    setup do
      @treasure = Treasure.new
    end

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
      assert_in_delta 153.7045, @treasure.longitude, 0.0001
    end

    should 'convert western hemisphere longitude fields to a negative float' do
      @treasure.update_attributes location(:longitude_hemisphere => 'W')
      assert_in_delta -153.7045, @treasure.longitude, 0.0001
    end

    should 'display a pretty #to_s' do
      @treasure.update_attributes location
      assert_equal "42°57.35′N, 153°42.27′E", @treasure.to_s
    end
  end

  private

  def location(params = {})
    { :latitude_degrees          => 42,
      :latitude_minutes          => 57,
      :latitude_decimal_minutes  => 35,
      :latitude_hemisphere       => 'N',
      :longitude_degrees         => 153,
      :longitude_minutes         => 42,
      :longitude_decimal_minutes => 27,
      :longitude_hemisphere      => 'E' }.merge params
  end

end
