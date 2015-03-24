class DiscountSerializer < MongoDocumentSerializer
  attributes :discount_rate,
             :title,
             :secret_key,
             :status,
             :duration,
             :duration_term,
             :hashtags,
             :categories

end
