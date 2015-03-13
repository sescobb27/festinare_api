module Cache
  module RedisCache
    class << self
      def instance
        @redis ||= Redis.new(db: 'hurryupdiscount', driver: :hiredis)
      end
    end
  end

  module MongoCache
    class << self
      def enable!
        Mongoid::QueryCache.enabled = true
      end

      def disable!
        Mongoid::QueryCache.enabled = false
      end
    end
  end
end

Cache::MongoCache.enable!
