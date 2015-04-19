class DiscountCache
  class << self
    def cache(discount, categories)
      obj = { discount: discount, categories: categories }
      Cache::RedisCache.instance do |redis|
        redis.rpush 'discounts', obj.to_json
      end
    end

    def invalidate
      invalidated = []
      Cache::RedisCache.instance do |redis|
        now = DateTime.now
        len = redis.llen('discounts')
        (0..len).each do
          redis.rpoplpush('discounts', 'discounts')
          obj = redis.lrange('discounts', 0, 0)[0]
          break if obj.nil?
          tmp = JSON.parse obj, symbolize_names: true
          expiry_time = DateTime.parse(tmp[:discount][:created_at]) +
                        (tmp[:discount][:duration] * 60).seconds
          if now >= expiry_time
            redis.lpop('discounts')
            invalidated << tmp
          end
        end
      end
      invalidated
    end

    def load
      Cache::RedisCache.instance do |redis|
        now = DateTime.now
        redis.pipelined do
          Client.has_active_discounts.batch_size(500).map do |client|
            client.discounts.each do |discount|
              if !discount.expired? && (now < discount.expire_time)
                tmp = { discount: discount, categories: client.categories }
                redis.rpush 'discounts', tmp.to_json
              end
            end
          end
        end
      end
    end

    def find_discounts_by_categories(categories)
      Cache::RedisCache.instance do |redis|
        len = redis.llen('discounts')
        redis.lrange('discounts', 0, len).select do |r_obj|
          obj = JSON.parse r_obj, symbolize_names: true
          # rubocop:disable Metrics/LineLength
          # intersection to see if any of the categories are in the discount's categories.
          # rubocop:enable Metrics/LineLength
          !(categories & obj[:categories]).empty?
        end.map(&:discount)
      end
    end
  end
end

