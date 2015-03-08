class DiscountCache
  class << self

    def cache discount
      redis = Cache::RedisCache.instance
      redis.rpush 'discounts', discount.to_json
    end

    def invalidate
      redis = Cache::RedisCache.instance
      now = DateTime.now.to_i
      len = redis.llen('discounts')
      (0..len).each do |x|
        redis.rpoplpush('discounts', 'discounts')
        obj = redis.lrange('discounts', 0, 0)[0]
        break if obj.nil?
        discount = JSON.parse(obj, symbolize_names: true)
        expiry_time = DateTime.parse(discount[:created_at]).to_i + (discount[:duration] * 60)
        if now > expiry_time
          redis.lpop('discounts')
        end
      end
    end

    def load
      redis = Cache::RedisCache.instance
      now = DateTime.now.to_i
      redis.pipelined do
        Client.batch_size(500).map do |client|
          client.discounts.each do |discount|
            expiry_time = discount.created_at.to_i + discount['duration'] * 60
            if discount.status && (now < expiry_time)
              redis.rpush 'discounts', discount.to_json
            end
          end
        end
      end
    end
  end
end
