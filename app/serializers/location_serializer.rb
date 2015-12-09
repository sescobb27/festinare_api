# == Schema Information
#
# Table name: locations
#
#  id          :integer          not null, primary key
#  latitude    :float
#  longitude   :float
#  address     :string
#  customer_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class LocationSerializer < ActiveModel::Serializer
  attributes :id, :latitude, :longitude, :address
end
