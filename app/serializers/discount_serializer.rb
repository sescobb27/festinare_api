class DiscountSerializer < MongoDocumentSerializer
  attributes :discount_rate,
             :title,
             :secret_key,
             :status,
             :created_at,
             :duration,
             :duration_term,
             :hashtags,
             :categories

end
