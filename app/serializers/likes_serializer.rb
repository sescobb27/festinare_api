class LikesSerializer < MongoDocumentSerializer
  attributes :name,
             :image_url,
             :addresses
  has_many :categories,
           :locations
end
