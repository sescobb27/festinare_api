class Client < ActiveRecord::Base
  include User
  # =============================relationships=================================
  has_many :client_plans
  has_many :plans, through: :client_plans
  has_many :discounts, inverse_of: :client
  # =============================END relationships=============================

  # =============================Schema========================================
  scope :has_active_discounts, -> { joins(:discounts).where(discounts: { status: true }) }
  # =============================END Schema====================================

  # =============================Schema Validations============================
  validates :name, presence: true
  # =============================END Schema Validations========================

  def plan?
    now = Time.zone.now
    !self.client_plans.with_discounts.empty? &&
      self.client_plans.with_discounts.one? do |plan|
        now < plan.expired_date
      end
  end

  def decrement_num_of_discounts_left!
    if self.client_plans.with_discounts.empty?
      raise Plan::PlanDiscountsExhausted
    else
      self.client_plans.with_discounts.first.inc num_of_discounts_left: -1
    end
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

  def self.review_client(id, review)
    client = Client.find id
    client.push feedback: review[:feedback], rates: review[:rate].to_i
    client.set avg_rate: client.rates.sum.fdiv(client.rates.length)
  end

  def self.available_discounts(categories, opts)
    query = Client.has_active_discounts
    query.in('categories.name' => categories) unless categories.empty?
    now = Time.zone.now
    threads = []
    query.limit(opts[:limit]).offset(opts[:offset]).each do |client|
      threads << Thread.new(client) do |t_client|
        Thread.current[:client] = t_client
        break if t_client.discounts.empty?
        Thread.current[:client].discounts = t_client.unexpired_discounts(now)
      end
      threads.map!(&:join) if threads.length >= ENV['POOL_SIZE'].to_i
    end

    threads.map do |thread|
      thread.join
      thread[:client] unless thread[:client].discounts.empty?
    end.compact
  end
end
