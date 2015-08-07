# == Schema Information
#
# Table name: customers
#
#  id                     :integer          not null, primary key
#  fullname               :string(100)      not null
#  categories             :string           default([]), is an Array
#  tokens                 :string           default([]), is an Array
#  username               :string(100)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  email                  :string(100)      not null
#  encrypted_password     :string           not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#

class CustomerSerializer < ActiveModel::Serializer
  attributes :id,
             :email,
             :username,
             :fullname,
             :categories
  has_many :customers_discounts,
           :mobiles
end
