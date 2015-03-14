class Plan
  include Mongoid::Document
  include Mongoid::Paranoia
  # =============================Schema========================================
    field :name
    field :description
    field :status, type: Boolean, default: true
    field :price, type: Integer
    field :num_of_discounts, type: Integer
    field :currency
    field :expired_rate, type: Integer # (1 .. 31) days or (1 .. 12) months
    field :expired_time # ( days or months )

    index({ name: 1 }, { unique: true, name: 'plan_name_index' })
    index({ status: 1 }, { unique: false, name: 'plan_status_index' })
  # =============================END Schema====================================

  default_scope -> { where(status: true).asc(:price) }

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
    plan.expired_date = DateTime.now + plan.expired_rate.send(plan.expired_time)
    plan.num_of_discounts_left = self.num_of_discounts
    plan
  end

  class PlanNotFound < StandardError; end
  class PlanDiscountsExhausted < StandardError; end
end
