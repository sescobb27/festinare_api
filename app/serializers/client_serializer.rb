class ClientSerializer < MongoDocumentSerializer
  attributes :email,
             :username,
             :name,
             :rate,
             :image_url,
             :addresses,
             :categories,
             :locations,
             :discounts,
             :client_plans
end
