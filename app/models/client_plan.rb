class ClientPlan < Plan
  # =============================relationships=================================
  embedded_in :client
  # =============================END relationships=============================
  # =============================Schema========================================
  field :expired_date, type: Time
  field :num_of_discounts_left, type: Integer
  scope :with_discounts, -> { active_plans.where(num_of_discounts_left: { '$gt' => 0 }) }
  # =============================END Schema====================================

  def self.invalidate_expired_ones
    now = Time.zone.now
    threads = []
    Client.batch_size(500).each do |client|
      threads << Thread.new(client) do |t_client|
        t_client.client_plans.map do |plan|
          next if now < plan.expired_date
          plan.update_attribute :status, false
          # rubocop:disable Metrics/LineLength
          Rails.logger.info <<-EOF
{ "action": "invalidate_plan", "id": "#{t_client._id}", "name": "#{t_client.name}", "plan": "#{plan.attributes}" }
EOF
          # rubocop:enable Metrics/LineLength
        end
      end
      threads.map!(&:join) if threads.length >= ENV['POOL_SIZE'].to_i
    end
    threads.map!(&:join)
  end
end
