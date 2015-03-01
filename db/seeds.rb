# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# categories = [
#   {
#     name: 'Bar',
#     description: ''
#   },
#   {
#     name: 'Disco',
#     description: ''
#   },
#   {
#     name: 'Restaurant',
#     description: ''
#   }
# ]

# if Category.count == 0
#   categories.each do |category|
#     Category.create category
#   end
# end
require 'ffaker'
require 'factory_girl_rails'
client = {
  categories: [
    Category.new(name: 'Bar'),
    Category.new(name: 'Disco')
  ],
  locations:  (1..5).map do
    Location.new latitude: Faker::Geolocation.lat, longitude: Faker::Geolocation.lng
  end,
  username:   'sescobb27',
  email:      'sescobb27@gmail.com',
  password:   'qwerty123!',
  name:       'Client Test',
  rate:       0.0,
  image_url:  'http://placehold.it/200x200',
  addresses:  []
}
Client.create! client
