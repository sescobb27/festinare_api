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

    index({ status: 1 }, { unique: false, name: 'discount_status_index' })
    index({ hashtags: 1 }, { unique: false, name: 'discount_hashtags_index' })
    default_scope -> { where(status: true) }
    DURATION_TERM = 'minutes'.freeze
    DURATIONS = [10, 20, 30, 60, 90, 120].freeze
  # =============================END Schema====================================

  # =============================Schema Validations============================
    validates_presence_of :discount_rate, :title, :secret_key
    validates :duration, inclusion: {
      in: DURATIONS,
      message: "Invalid Discount duration, valid ones are #{DURATIONS.join(', ')}"
    }
  # =============================END Schema Validations========================

    def expired?
      !self.status
    end

    def self.invalidate_expired_ones
      mongo_thread = Thread.new do
        now = DateTime.now
        threads = []
        threads = Client.batch_size(500).map do |client|
          Thread.new(client) do |t_client|
            t_client.discounts.map do |discount|
              expire_time = discount.created_at + (discount.duration * 60).seconds
              if now >= expire_time
                discount.update_attribute :status, false
                Rails.logger.info "CLIENT: { id: #{t_client._id}, name: #{t_client.name} }\nDISCOUNT(invalidated): #{discount.inspect}"
              end
            end
          end
        end
        threads.map!(&:join)
      end

      cache_thread = Thread.new do
        invalidated = DiscountCache::invalidate
        Rails.logger.info "DISCOUNTS_CACHE(invalidated): #{invalidated}"
      end

      mongo_thread.join
      cache_thread.join
    end
end
