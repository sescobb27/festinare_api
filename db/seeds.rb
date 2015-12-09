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

default_plans = [
  {
    name: 'Hurry Up!',
    description: 'Now! now! now!, time is over!!!! - (not available yet)',
    price: 10_000,
    currency: 'COP',
    num_of_discounts: 1,
    expired_rate: 1,
    expired_time: 'day'
  },
  {
    name: 'Discount Novice!',
    description: '10% de ahorro - (not available yet)',
    price: 90_000,
    currency: 'COP',
    num_of_discounts: 10,
    expired_rate: 1,
    expired_time: 'month'
  },
  {
    name: 'Discount Assassin!',
    description: '15% de ahorro - (not available yet)',
    price: 127_500,
    currency: 'COP',
    num_of_discounts: 15,
    expired_rate: 1,
    expired_time: 'month'
  },
  {
    name: 'Discount Machine!',
    description: '20% de ahorro - (not available yet)',
    price: 240_000,
    currency: 'COP',
    num_of_discounts: 30,
    expired_rate: 1,
    expired_time: 'month'
  }
]
puts 'Creating plans'
Plan.create! default_plans if Plan.count == 0
puts 'End creating plans'

if Rails.env.production?
  unless Plan.where(name: 'Beta Discount').exists?
    puts 'Creating Beta Plan'
    Plan.create! name: 'Beta Discount',
                 description: 'Beta Test Discount',
                 price: 0,
                 currency: 'COP',
                 num_of_discounts: 1_000,
                 expired_rate: 2,
                 expired_time: 'months'
    puts 'End creating Beta Plan'
  end
end

if Rails.env.development?
  clients = [
    {
      categories: ['Bar', 'Disco'],
      username:   'sescobb27',
      email:      'yepeto@gmail.com',
      password:   'qwerty123!',
      name:       'Client Test',
      image_url:  'http://placehold.it/200x200',
      addresses:  []
    },
    {
      username:   'test4echo',
      email:      'sescobb27@notemail.com',
      password:   'qwerty123!',
      name:       'test4echo Test',
      image_url:  '',
      addresses:  []
    },
    {
      categories: ['Bar', 'Restaurant'],
      username:   'sescob',
      email:      'test4echo@notemail.com',
      password:   'qwerty123!',
      name:       'Client Test Plan',
      image_url:  '',
      addresses:  []
    }
  ]
  puts 'Creating fixed clients'
  Client.create! clients if Client.count == 0
  ClientsPlan.create_from_plan(Client.last, Plan.all.sample)
  puts 'End creating fixed clients'

  puts 'Creating 100 random clients with discounts'
  FactoryGirl.create_list :client_with_discounts, 100
  puts 'Finished creating 100 random clients with discounts'
  # user = FactoryGirl.create :user
  # token = API::BaseController.new.authenticate_user user
  # puts "Finished creating fake user: TOKEN=#{token}"
end
