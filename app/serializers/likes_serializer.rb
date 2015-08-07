class LikesSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :image_url,
             :addresses
end
