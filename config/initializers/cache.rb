
require 'connection_pool'
pool_size = Integer(ENV['WEB_CONCURRENCY'] || 2) *
            Integer(ENV['PUMA_MAX_THREADS'] || 16)

REDIS_POOL = ConnectionPool.new(size: pool_size, timeout: 30) do
  Redis.new(db: 'hurryupdiscount', driver: :hiredis)
end

module Cache
  module RedisCache
    class << self
      def instance
        REDIS_POOL.with do |conn|
          yield conn
        end
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
