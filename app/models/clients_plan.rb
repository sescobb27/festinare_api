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

# @author Simon Escobar
class ClientsPlan < ActiveRecord::Base
  # =============================relationships=================================
  belongs_to :client, inverse_of: :clients_plans
  belongs_to :plan, inverse_of: :clients_plans
  # =============================END relationships=============================
  # =============================Schema========================================
  scope :active_plans, -> { where(status: true) }
  scope :with_discounts, -> { active_plans.where('num_of_discounts_left > :num', num: 0) }
  # =============================END Schema====================================

  class PlanNotFound < StandardError; end
  class PlanDiscountsExhausted < StandardError; end
end
