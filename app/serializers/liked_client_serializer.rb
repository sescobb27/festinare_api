class LikedClientSerializer < MongoDocumentSerializer
  attributes :name,
             :avg_rate,
             :image_url,
             :addresses
  has_many :categories,
           :locations
end
