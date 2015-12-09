# == Schema Information
#
# Table name: clients_plans
#
#  id                    :integer          not null, primary key
#  client_id             :integer
#  plan_id               :integer
#  num_of_discounts_left :integer          not null
#  status                :boolean          default(TRUE)
#  expired_date          :datetime         not null
#  created_at            :datetime         not null
#

class ClientsPlanSerializer < ActiveModel::Serializer
  attributes :id,
             :client_id,
             :status,
             :expired_date,
             :num_of_discounts_left,
             :created_at
  has_one :plan
end
