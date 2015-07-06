class ReviewSerializer < MongoDocumentSerializer
  attributes :rate, :feedback

  belongs_to :user, :client
end
