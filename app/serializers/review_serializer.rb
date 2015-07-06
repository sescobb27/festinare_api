class ReviewSerializer < MongoDocumentSerializer
  attributes :rate, :feedback

  has_one :user_id, :client_id

  def user_id
    object.user_id.to_s
  end

  def client_id
    object.client_id.to_s
  end
end
