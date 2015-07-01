module Cache
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
