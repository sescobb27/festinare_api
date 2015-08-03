# == Schema Information
#
# Table name: plans
#
#  id               :integer          not null, primary key
#  name             :string(40)       not null
#  description      :text
#  price            :integer          not null
#  num_of_discounts :integer          not null
#  currency         :string           not null
#  expired_rate     :integer          not null
#  expired_time     :string           not null
#  deleted_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class PlanSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :description,
             :status,
             :price,
             :num_of_discounts,
             :currency,
             :expired_rate,
             :expired_time
end
