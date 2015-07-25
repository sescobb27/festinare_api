class ClientSerializer < ActiveModel::Serializer
  attributes :id,
             :email,
             :username,
             :name,
             :image_url,
             :addresses
  has_many :categories,
           :locations,
           :discounts,
           :client_plans

  has_many :reviews, embed: :ids
end
