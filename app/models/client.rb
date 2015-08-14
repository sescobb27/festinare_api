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

class Client < ActiveRecord::Base
  include User
  # =============================relationships=================================
  has_many :clients_plans, inverse_of: :client
  has_many :plans, through: :clients_plans
  has_many :discounts, inverse_of: :client
  has_many :customers_discounts,  through: :discounts
  # =============================END relationships=============================

  # =============================Schema========================================
  scope :with_active_discounts, -> { includes(:discounts).where(discounts: { status: true }) }
  # =============================END Schema====================================

  # =============================Schema Validations============================
  validates :name, presence: true
  # =============================END Schema Validations========================

  def plan?
    now = Time.zone.now
    !self.clients_plans.with_discounts.empty? &&
      self.clients_plans.with_discounts.one? do |plan|
        now < plan.expired_date
      end
  end

  def decrement_num_of_discounts_left!
    fail ClientsPlan::PlanDiscountsExhausted unless self.plan?

    current_plan = self.clients_plans.with_discounts.last
    current_plan.num_of_discounts_left -= 1
    current_plan.save
    self
  end

  def unexpired_discounts(time)
    self.discounts.select { |discount| !discount.expired? time }
  end

  def update_password(credentials)
    unless self.valid_password? credentials[:current_password]
      self.errors.add :password, 'Invalid'
      return false
    end

    self.password = credentials[:password]
    self.password_confirmation = credentials[:password_confirmation]

    self.save
  end

  def self.available_discounts(categories = [], opts = {})
    query = Client.with_active_discounts
    query.where(':categories = ANY (categories)', categories: categories) unless categories.empty?
    now = Time.zone.now

    query.limit(opts[:limit]).offset(opts[:offset]).map do |client|
      break if client.discounts.empty?
      client.discounts = client.unexpired_discounts(now)
      client unless client.discounts.empty?
    end.compact
  end
end
