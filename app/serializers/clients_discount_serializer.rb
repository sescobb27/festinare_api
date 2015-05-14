class ClientsDiscountSerializer < MongoDocumentSerializer
  attributes :name,
             :rates
  has_many :discounts,
           :addresses,
           :categories,
           :locations
end
