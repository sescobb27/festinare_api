class CustomerSerializer < ActiveModel::Serializer
  attributes :id,
             :email,
             :username,
             :fullname
  has_many :locations, :categories, :discounts
  has_one :mobile
end
