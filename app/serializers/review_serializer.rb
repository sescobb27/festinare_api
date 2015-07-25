class ReviewSerializer < ActiveModel::Serializer
  attributes :id, :rate, :feedback

  has_one :customer_id, :client_id
end
