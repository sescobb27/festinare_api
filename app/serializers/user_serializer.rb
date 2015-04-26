class UserSerializer < MongoDocumentSerializer
  attributes :email,
             :username,
             :lastname,
             :name
  has_many :locations, :categories, :discounts
  has_one :mobile
end
