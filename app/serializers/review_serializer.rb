class ReviewSerializer < MongoDocumentSerializer
  attributes :rate, :feedback

  has_one :customer_id, :client_id

  def customer_id
    object.customer_id.to_s
  end

  def client_id
    object.client_id.to_s
  end
end
