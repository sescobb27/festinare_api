class ClientSerializer < MongoDocumentSerializer
  attributes :email,
             :username,
             :name,
             :avg_rate,
             :image_url,
             :addresses
  has_many :categories,
           :locations,
           :discounts,
           :client_plans
end
