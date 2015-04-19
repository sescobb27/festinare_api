class UserSerializer < MongoDocumentSerializer
  attributes :email,
             :username,
             :lastname,
             :name,
             :locations,
             :discounts,
             :categories,
             :mobile
end
