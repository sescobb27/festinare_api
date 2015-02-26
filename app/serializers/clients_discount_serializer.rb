class ClientsDiscountSerializer < ActiveModel::Serializer
  attributes :_id, :name, :rate, :discounts, :addresses, :categories, :locations
end
