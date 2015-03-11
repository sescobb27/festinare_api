namespace :invalidate do
  desc "Search client's discounts and invalidate the expired ones"
  task discounts: :environment do
    mongo_thread = Thread.new do
      now = DateTime.now
      threads = []
      max_threads = ENV['MAX_THREADS'].to_i || 1000
      Client.batch_size(500).each do |client|
        threads << Thread.new(client) do |t_client|
          t_client.discounts.each do |discount|
            expire_time = discount.created_at + (discount.duration * 60).seconds
            if now > expire_time
              discount.update_attribute :status, false
              Rails.logger.info "CLIENT: { id: #{t_client._id}, name: #{t_client.name} }\nDISCOUNT(invalidated): #{discount.inspect}"
            end
          end
        end
        if threads.length >= max_threads
          threads.map(&:join)
          threads.clear
        end
      end
      threads.map(&:join)
    end

    cache_thread = Thread.new do
      invalidated = DiscountCache::invalidate
      Rails.logger.info "DISCOUNTS_CACHE(invalidated): #{invalidated}"
    end

    mongo_thread.join
    cache_thread.join
  end

end
