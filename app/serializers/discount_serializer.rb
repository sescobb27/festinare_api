class DiscountSerializer < MongoDocumentSerializer
  attributes :discount_rate,
             :title,
             :status,
             :created_at,
             :duration,
             :duration_term,
             :hashtags
  has_many :categories
end
