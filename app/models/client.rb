# == Schema Information
#
# Table name: clients
#
#  id                     :integer          not null, primary key
#  name                   :string(120)      not null
#  categories             :string           default([]), is an Array
#  tokens                 :string           default([]), is an Array
#  username               :string(100)
#  image_url              :string
#  addresses              :string           default([]), is an Array
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  email                  :string(100)      not null
#  encrypted_password     :string           not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#

# @author Simon Escobar
class Client < ActiveRecord::Base
  include User
  # =============================relationships=================================
  has_many :clients_plans, inverse_of: :client
  has_many :plans, through: :clients_plans
  has_many :discounts, inverse_of: :client
  has_many :customers_discounts, through: :discounts
  # =============================END relationships=============================

  # =============================Schema========================================
  scope :with_active_discounts, -> { includes(:discounts).where(discounts: { status: true }) }
  # =============================END Schema====================================

  # =============================Schema Validations============================
  validates :name, presence: true
  # =============================END Schema Validations========================

  # Returns if client has an active plan
  # @return [Boolean] true if the plan isn't expired at the current time
  #   and has 1 or more discounts available, false otherwhise
  def plan?
    now = Time.zone.now

    have_discounts = clients_plans.with_discounts
    !have_discounts.empty? && have_discounts.any? do |plan|
      now < plan.expired_date
    end
  end

  def decrement_num_of_discounts_left!
    fail ClientsPlan::PlanDiscountsExhausted unless plan?
    decrement_num_of_discounts_left
  end

  def decrement_num_of_discounts_left
    current_plan = clients_plans.with_discounts.last
    current_plan.num_of_discounts_left -= 1
    current_plan.save
    self
  end

  # Returns all client discounts which have not been expired
  # @param time [Time]
  # @return [Array]
  def unexpired_discounts(time)
    discounts.select { |discount| !discount.expired? time }
  end

  # Returns a newly created Client's Plan
  # @param plan [Plan] an already created Plan object
  # @return [ClientsPlan]
  def purchase(plan)
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
    ClientsPlan.new(
      plan_id: plan.id,
      client_id: id, # self.id
      expired_date: Time.zone.now + plan.expired_rate.send(plan.expired_time),
      num_of_discounts_left: plan.num_of_discounts
    ).tap do |clients_plan|
      yield clients_plan if block_given?
      clients_plan.save
    end
  end
end
