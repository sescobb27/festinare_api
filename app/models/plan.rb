class Plan < ActiveRecord::Base
  # =============================relationships=================================
  has_many :client_plans
  has_many :clients, through: :client_plans
  # =============================END relationships=============================
  # =============================Schema========================================
  EXPIRED_TIMES = %w(day days month months).freeze
  scope :active_plans, -> { where(status: true).asc(:price) }
  # =============================END Schema====================================

  # =============================Schema Validations============================
  validates :name,
            :description,
            :price,
            :num_of_discounts,
            :currency,
            :expired_rate,
            presence: true
  validates :expired_time, inclusion: { in: EXPIRED_TIMES }
  validates :price, numericality: { only_integer: true }
  validates :num_of_discounts, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1
  }
  validates :expired_rate, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 31
  }
  # =============================END Schema Validations========================

  def to_client_plan
    plan = ClientPlan.new self.clone.attributes
    plan._type = 'ClientPlan'
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
    plan.expired_date = Time.zone.now +
      plan.expired_rate.send(plan.expired_time)
    plan.num_of_discounts_left = self[:num_of_discounts]
    plan
  end

  class PlanNotFound < StandardError; end
  class PlanDiscountsExhausted < StandardError; end
end
