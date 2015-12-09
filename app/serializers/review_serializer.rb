class ReviewSerializer < ActiveModel::Serializer
  attributes :id, :feedback, :rate, :created_at, :updated_at

  has_one :customer, :discount, embed: :ids
end
