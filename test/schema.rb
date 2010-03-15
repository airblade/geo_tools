ActiveRecord::Schema.define(:version => 0) do
  create_table :treasures, :force => true do |t|
    t.string  :name
    t.integer :latitude_degrees,  :latitude_minutes,  :latitude_decimal_minutes, :latitude_decimal_minutes_width
    t.string  :latitude_hemisphere
    t.integer :longitude_degrees, :longitude_minutes, :longitude_decimal_minutes, :longitude_decimal_minutes_width
    t.string  :longitude_hemisphere
  end
end
