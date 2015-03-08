module Cache
  module RedisCache
    class << self
      def instance
        @redis ||= Redis.new(db: 'hurryupdiscount', driver: :hiredis)
      end
    end
  end
end
