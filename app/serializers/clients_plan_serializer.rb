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

class ClientPlanSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :description,
             :status,
             :price,
             :num_of_discounts,
             :currency,
             :expired_rate,
             :expired_time,
             :expired_date,
             :num_of_discounts_left
end
