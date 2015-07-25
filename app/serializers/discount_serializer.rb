class DiscountSerializer < ActiveModel::Serializer
  attributes :id,
             :discount_rate,
             :title,
             :status,
             :created_at,
             :duration,
             :duration_term,
             :hashtags
  has_many :categories
end
