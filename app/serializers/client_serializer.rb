class ClientSerializer < MongoDocumentSerializer
  attributes :email,
             :username,
             :name,
             :image_url,
             :addresses
  has_many :categories,
           :locations,
           :discounts,
           :client_plans

  has_many :reviews, embed: :ids
end
