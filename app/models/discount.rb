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
class Discount < ActiveRecord::Base
  include Qr
  # =============================relationships=================================
  belongs_to :client, inverse_of: :discounts
  has_many :customers_discounts
  has_many :customers, through: :customers_discounts
  scope :not_expired, lambda {
    where("\"discounts\".\"created_at\" < (now() + (\"discounts\".\"duration\" * 60 || 'seconds')::interval)")
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

  def self.invalidate_expired_ones
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

  def self.discount_categories
    # ==========================================================================
    # SELECT DISTINCT "clients"."*", "discounts"."*"
    # FROM "clients"
    # LEFT OUTER JOIN "discounts"
    # ON "discounts"."client_id" = "clients"."id"
    # WHERE "discounts"."status" = 't'
    # AND ("discounts"."created_at" < (now() + ("discounts"."duration" * 60 || 'seconds')::interval))
    # ==========================================================================
    Client
      .select(:categories)
      .distinct
      .with_active_discounts
      .merge(Discount.not_expired)
      .map(&:categories).flatten.uniq
  end
end
