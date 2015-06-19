class UserSerializer < MongoDocumentSerializer
  attributes :email,
             :username,
             :fullname
  has_many :locations, :categories, :discounts
  has_one :mobile
end
