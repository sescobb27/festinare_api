class DiscountCache
  class << self
    redis = Cache::RedisCache.instance

    def cache discount
      discount.created_at = Time.now
      redis.rpush 'discounts', discount
    end

    def invalidate
      redis = Cache::RedisCache.instance
      now = DateTime.now.to_i
      len = redis.llen('discount')
      (0..len).each do |x|
        redis.rpoplpush('discount', 'discount')
        obj = redis.lrange('discount', 0, 0)[0]
        break if obj.nil?
        discount = JSON.parse()
        expiry_time = DateTime.parse(discount['created_at']).to_i + (discount['duration'] * 60)
        if now > expiry_time
          redis.lpop('discount')
        end
      end
    end

    def load

    end
  end
end
