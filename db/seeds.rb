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
if Client.count == 0
  Client.create! client
end

default_plans = [
  {
    name: 'Hurry Up!',
    description: '',
    price: 10000,
    currency: 'COP',
    num_of_discounts: 1,
    expired_rate: 1,
    expired_time: 'day'
  },
  {
    name: 'Discount Novice!',
    description: '10% de ahorro',
    price: 90000,
    currency: 'COP',
    num_of_discounts: 10,
    expired_rate: 1,
    expired_time: 'month'
  },
  {
    name: 'Discount Assassin!',
    description: '15% de ahorro',
    price: 127500,
    currency: 'COP',
    num_of_discounts: 15,
    expired_rate: 1,
    expired_time: 'month'
  },
  {
    name: 'Discount Machine!',
    description: '20% de ahorro',
    price: 240000,
    currency: 'COP',
    num_of_discounts: 30,
    expired_rate: 1,
    expired_time: 'month'
  }
]
if Plan.count == 0
  Plan.create! default_plans
end
