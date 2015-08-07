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

class ClientsPlan < ActiveRecord::Base
  # =============================relationships=================================
  belongs_to :client, inverse_of: :clients_plans
  belongs_to :plan, inverse_of: :clients_plans
  # =============================END relationships=============================
  # =============================Schema========================================
  scope :active_plans, -> { where(status: true) }
  scope :with_discounts, -> { active_plans.where('"clients_plans"."num_of_discounts_left" > :num', num: 0) }
  # =============================END Schema====================================

  def self.invalidate_expired_ones
    now = Time.zone.now
    Client.joins(:clients_plans).where(clients_plans: { status: true }).find_each do |client|
      client.clients_plans.map do |plan|
        next if now < plan.expired_date
        plan.update status: false
        # rubocop:disable Metrics/LineLength
        Rails.logger.info <<-EOF
{ "action": "invalidate_plan", "id": "#{client.id}", "name": "#{client.name}", "plan": "#{plan.attributes}" }
EOF
        # rubocop:enable Metrics/LineLength
      end
    end
  end

  def self.create_from_plan(client, plan)
    # the purchased plan is going to expire depending on the plan specifications
    # so for example:
    # DateTime.now => Thu, 12 Mar 2015 21:17:33 -0500
    # plan => {
    #             :currency => "COP",
    #           :deleted_at => nil,
    #          :description => "15% de ahorro",
    #         :expired_rate => 1,
    #         :expired_time => "month",
    #                 :name => "Hurry Up!",
    #     :num_of_discounts => 15,
    #                :price => 127500,
    #               :status => true
    # }
    # the purchased_plan.expired_date = Thu, 12 Apr 2015 21:17:33 -0500
    # 1 month after today
    ClientsPlan.new.tap do |clients_plan|
      clients_plan.plan_id = plan.id
      clients_plan.client_id = client.id
      clients_plan.expired_date = Time.zone.now +
        plan.expired_rate.send(plan.expired_time)
      clients_plan.num_of_discounts_left = plan.num_of_discounts
      yield clients_plan if block_given?
      clients_plan.save
    end
  end
  class PlanNotFound < StandardError; end
  class PlanDiscountsExhausted < StandardError; end
end
