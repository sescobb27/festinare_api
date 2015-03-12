class DiscountCache
  class << self

    def cache discount, categories
      obj = { discount: discount, categories: categories }
      redis = Cache::RedisCache.instance
      redis.rpush 'discounts', obj.to_json
    end

    def invalidate
      redis = Cache::RedisCache.instance
      now = DateTime.now
      len = redis.llen('discounts')
      invalidated = []
      (0..len).each do |x|
        redis.rpoplpush('discounts', 'discounts')
        obj = redis.lrange('discounts', 0, 0)[0]
        break if obj.nil?
        tmp = JSON.parse obj, symbolize_names: true
        expiry_time = DateTime.parse(tmp[:discount][:created_at]) + (tmp[:discount][:duration] * 60).seconds
        if now >= expiry_time
          redis.lpop('discounts')
          invalidated << tmp
        end
      end
      return invalidated
    end

    def load
      redis = Cache::RedisCache.instance
      now = DateTime.now
      redis.pipelined do
        Client.batch_size(500).map do |client|
          client.discounts.each do |discount|
            expiry_time = discount.created_at + (discount['duration'] * 60).seconds
            if !discount.expired? && (now < expiry_time)
              tmp = { discount: discount, categories: client.categories }
              redis.rpush 'discounts', tmp.to_json
            end
          end
        end
      end
    end

    def find_discounts_by_categories categories
      redis = Cache::RedisCache.instance
      len = redis.llen('discounts')
      redis.lrange('discounts', 0, len).select do |r_obj|
        obj = JSON.parse r_obj, symbolize_names: true
        !(categories & obj[:categories]).empty? # intersection to see if any of the categories are in the discount's categories:
      end.map(&:discount)
    end
  end
end

