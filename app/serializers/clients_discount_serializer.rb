class ClientsDiscountSerializer < ActiveModel::Serializer
  attributes :id, :name
  has_many :discounts,
           :addresses,
           :categories,
           :locations
  has_many :reviews, embed: :ids
end
