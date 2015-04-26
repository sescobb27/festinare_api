class ClientsDiscountSerializer < MongoDocumentSerializer
  attributes :name,
             :rate
  has_many :discounts,
           :addresses,
           :categories,
           :locations
end
