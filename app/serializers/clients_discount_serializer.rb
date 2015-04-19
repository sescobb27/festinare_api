class ClientsDiscountSerializer < MongoDocumentSerializer
  attributes :name,
             :rate,
             :discounts,
             :addresses,
             :categories,
             :locations
end
