class Discount
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Paranoia
  # =============================relationships=================================
  embeds_many :categories, as: :categorizable
  embedded_in :discountable, polymorphic: true
  # =============================END relationships=============================
  # =============================Schema========================================
  field :discount_rate, type: Integer
  field :title
  field :secret_key
  field :status, type: Boolean, default: true
  field :duration, type: Integer
  field :duration_term
  field :hashtags, type: Array

  index({ status: 1 }, unique: false)
  index({ hashtags: 1 }, unique: false)
  default_scope -> { where(status: true) }

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
  validates_presence_of :discount_rate, :title, :secret_key
  validates :duration, inclusion: {
    in: DURATIONS,
    message: "Invalid Discount duration, valid ones are #{DURATIONS.join(", ")}"
  }
  # =============================END Schema Validations========================

  def expired?
    !self[:status]
  end

  def expire_time
    self[:created_at] + (self[:duration] * 60).seconds
  end

  def self.invalidate_expired_ones
    mongo_thread = Thread.new do
      now = Time.zone.now
      threads = Client.has_active_discounts.batch_size(500).map do |client|
        Thread.new(client) do |t_client|
          t_client.discounts.map do |discount|
            next if now < discount.expire_time
            discount.update_attribute :status, false
            # rubocop:disable Metrics/LineLength
            Rails.logger.info <<-EOF
{ "action": "invalidate_discount", "id": "#{t_client._id}", "name": "#{t_client.name}", "discount": "#{discount.attributes}" }
EOF
            # rubocop:enable Metrics/LineLength
          end
        end
      end
      threads.map!(&:join)
    end

    cache_thread = Thread.new do
      invalidated = DiscountCache.invalidate
      invalidated.each do |discount|
        Rails.logger.info <<-EOF
{ "action": "invalidate_discount_cache", "discount": "#{discount}" }
EOF
      end
    end

    mongo_thread.join
    cache_thread.join
  end

  def self.discount_categories
    categories = nil
    Cache::RedisCache.instance do |redis|
      len = redis.llen('discounts')
      if len > 0
        redis.lrange('discounts', 0, len).map do |r_discount|
          result = JSON.parse r_discount, symbolize_names: true
          categories = result[:categories].map { |category| category[:name] }
        end
      end
    end

    if !categories || categories.empty?
      now = Time.zone.now
      threads = Client.has_active_discounts.batch_size(500).map do |client|
        Thread.new(client) do |t_client|
          Thread.current[:categories] = []
          t_client.discounts.map do |discount|
            if now < discount.expire_time
              Thread.current[:categories].push discount.categories.map(&:name)
            end
          end
        end
      end
      categories = []
      threads.map do |thread|
        thread.join
        categories.concat thread[:categories]
      end
    end

    categories.flatten
  end
end
