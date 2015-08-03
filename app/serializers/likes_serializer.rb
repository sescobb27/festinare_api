class LikesSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :image_url,
             :addresses
  has_many :categories
           # :locations
end
