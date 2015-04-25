# rubocop:disable Metrics/LineLength
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
# rubocop:enable Metrics/LineLength
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

default_plans = [
  {
    name: 'Hurry Up!',
    description: 'Now! now! now!, time is over!!!!',
    price: 10_000,
    currency: 'COP',
    num_of_discounts: 1,
    expired_rate: 1,
    expired_time: 'day'
  },
  {
    name: 'Discount Novice!',
    description: '10% de ahorro',
    price: 90_000,
    currency: 'COP',
    num_of_discounts: 10,
    expired_rate: 1,
    expired_time: 'month'
  },
  {
    name: 'Discount Assassin!',
    description: '15% de ahorro',
    price: 127_500,
    currency: 'COP',
    num_of_discounts: 15,
    expired_rate: 1,
    expired_time: 'month'
  },
  {
    name: 'Discount Machine!',
    description: '20% de ahorro',
    price: 240_000,
    currency: 'COP',
    num_of_discounts: 30,
    expired_rate: 1,
    expired_time: 'month'
  }
]
Plan.create! default_plans if Plan.count == 0

if Rails.env == 'development'
  clients = [
    {
      categories: [
        Category.new(name: 'Bar'),
        Category.new(name: 'Disco')
      ],
      locations:  (1..5).map do
        Location.new latitude: FFaker::Geolocation.lat,
                     longitude: FFaker::Geolocation.lng
      end,
      username:   'sescobb27',
      email:      'yepeto@gmail.com',
      password:   'qwerty123!',
      name:       'Client Test',
      rate:       0.0,
      image_url:  'http://placehold.it/200x200',
      addresses:  []
    },
    {
      locations:  (1..5).map do
        Location.new latitude: FFaker::Geolocation.lat,
                     longitude: FFaker::Geolocation.lng
      end,
      username:   'test4echo',
      email:      'sescobb27@notemail.com',
      password:   'qwerty123!',
      name:       'test4echo Test',
      rate:       0.0,
      image_url:  '',
      addresses:  []
    },
    {
      categories: [
        Category.new(name: 'Bar'),
        Category.new(name: 'Restaurant')
      ],
      locations:  (1..5).map do
        Location.new latitude: FFaker::Geolocation.lat,
                     longitude: FFaker::Geolocation.lng
      end,
      client_plans: [Plan.all.sample.to_client_plan],
      username:   'sescob',
      email:      'test4echo@notemail.com',
      password:   'qwerty123!',
      name:       'Client Test Plan',
      rate:       0.0,
      image_url:  '',
      addresses:  []
    }
  ]
  Client.create! clients if Client.count == 0
end
