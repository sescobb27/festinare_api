class ClientsDiscountSerializer < ActiveModel::Serializer
  attributes :id, :name, :categories
  has_many :discounts, :addresses

  has_many :customers_discounts, embed: :ids
end
