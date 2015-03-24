class MongoDocumentSerializer < ActiveModel::Serializer
  attributes :_id

  def _id
    object._id.to_s
  end
end
