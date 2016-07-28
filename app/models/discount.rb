# == Schema Information
#
# Table name: discounts
#
#  id            :integer          not null, primary key
#  discount_rate :integer          not null
#  title         :string(100)      not null
#  secret_key    :string           not null
#  status        :boolean          default(TRUE)
#  duration      :integer          not null
#  duration_term :string           default("minutes")
#  hashtags      :string           default([]), is an Array
#  client_id     :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

# @author Simon Escobar
class Discount < ActiveRecord::Base
  include Qr
  # =============================relationships=================================
  belongs_to :client, inverse_of: :discounts
  has_many :customers_discounts
  has_many :customers, through: :customers_discounts
  scope :active, -> { where(status: true) }
  scope :not_expired, lambda {
    active.where("discounts.created_at < (now() + (duration * 60 || 'seconds')::interval)")
  }
  # =============================END relationships=============================
  # =============================Schema========================================

  DURATION_TERM = 'minutes'.freeze
  DURATIONS = [
    10,  # 10 minutes
    20,  # 20 minutes
    30,  # 30 minutes
    60,  # 1 hour             => 60 minutes
    90,  # 1 hour 30 minutes  => 90 minutes
    120, # 2 hours            => 120 minutes
    150, # 2 hours 30 minutes => 150 minutes
    180, # 3 hours            => 180 minutes
    300, # 5 hours            => 300 minutes
    360  # 6 hours            => 360 minutes
  ].freeze
  # =============================END Schema====================================

  # =============================Schema Validations============================
  validates :discount_rate, :title, :duration, presence: true
  validates :duration, inclusion: {
    in: DURATIONS,
    message: "Invalid Discount duration, valid ones are #{DURATIONS.join(", ")}"
  }
  # =============================END Schema Validations========================

  # Returns if a discount is expired
  # @param time [Time]
  # @return [Boolean] true if discount status == true and given time is greater
  #   than discount's expire time
  def expired?(time)
    if status # if is active
      time > expire_time
    else
      true
    end
  end

  def expire_time
    created_at + (duration * 60).seconds
  end

  # Invalidate Expired Discounts
  def self.invalidate!
    now = Time.zone.now
    # ==========================================================================
    # SELECT "clients"."*", "discounts"."*"
    # FROM "clients"
    # LEFT OUTER JOIN "discounts"
    # ON "discounts"."client_id" = "clients"."id"
    # WHERE "discounts"."status" = 't'
    # ==========================================================================
    Client.with_active_discounts.find_each do |client|
      client.discounts.map do |discount|
        next unless discount.expired? now
        discount.update status: false
        # rubocop:disable Metrics/LineLength
        Rails.logger.info <<-EOF
{ "action": "invalidate_discount", "id": "#{client.id}", "name": "#{client.name}", "discount": "#{discount.attributes}" }
EOF
        # rubocop:enable Metrics/LineLength
      end
    end
  end

  def same_secret_key?(key)
    # TODO: CRYPTO STUFF
    secret_key == key
  end

  def self.redeem(discount, secret_key)
    fail SecretKeyNotMatchError unless discount.same_secret_key? secret_key
    customers_discount = discount.customers_discounts.first
    fail AlreadyRedeemedError if customers_discount.redeemed
    customers_discount.redeemed = true
    customers_discount.save
  end

  def self.categories
    # ==========================================================================
    # SELECT DISTINCT UNNEST(categories)
    # FROM "clients"
    # LEFT OUTER JOIN "discounts"
    # ON "discounts"."client_id" = "clients"."id"
    # WHERE "discounts"."status" = $1
    # AND ("discounts"."created_at" < (now() + ("discounts"."duration" * 60 || 'seconds')::interval))  [["status", "t"]]
    # ==========================================================================
    Client.select('UNNEST(categories)')
      .distinct
      .with_active_discounts
      .merge(Discount.not_expired)
      .pluck('UNNEST(categories)')
  end


  # Returns all available discounts given a set of categories and filters
  # @param opts [Hash] valid options are = { omit: [Fixnum] limit: Fixnum offset: Fixnum }
  # @return [Array<Discount>]
  def self.available(categories = [], opts = {})
    query = Discount.joins(:client).where(discounts: { status: true })
    query.where(':categories = ANY ("client"."categories")', categories: categories) unless categories.empty?
    query.where.not(discounts: { id: opts[:omit] }) if opts[:omit]
    now = Time.zone.now

    query.limit(opts[:limit]).offset(opts[:offset]).to_a.select do |discount|
      !discount.expired? now
    end
  end

  class SecretKeyNotMatchError < StandardError; end
  class AlreadyRedeemedError < StandardError; end
end
