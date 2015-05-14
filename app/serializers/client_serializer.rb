class ClientSerializer < MongoDocumentSerializer
  attributes :email,
             :username,
             :name,
             :rates,
             :image_url,
             :addresses
  has_many :categories,
           :locations,
           :discounts,
           :client_plans
end
