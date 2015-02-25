class ClientsDiscountSerializer < ActiveModel::Serializer
  attributes :id, :name, :rate, :discounts, :addresses, :locations
end
