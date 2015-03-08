namespace :invalidate do
  desc "Search client's discounts and invalidate the expired ones"
  task discounts: :environment do
    now = DateTime.now.to_i
    threads = []
    max_threads = ENV['MAX_THREADS'].to_i || 200
    Client.batch_size(500).each do |client|
      threads << Thread.new(client) do |t_client|
        t_client.discounts.each do |discount|
          expire_time = discount.created_at.to_i + (discount.duration * 60)
          if now > expire_time
            discount.update_attributes status: false
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

end
