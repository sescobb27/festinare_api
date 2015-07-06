class ClientsDiscountSerializer < MongoDocumentSerializer
  attributes :name
  has_many :discounts,
           :addresses,
           :categories,
           :locations
  has_many :reviews, embed: :ids
end
