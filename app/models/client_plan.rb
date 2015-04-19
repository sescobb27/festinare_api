class ClientPlan < Plan
  # =============================relationships=================================
  embedded_in :client
  # =============================END relationships=============================
  # =============================Schema========================================
  field :expired_date, type: DateTime
  field :num_of_discounts_left, type: Integer
  default_scope -> { where(status: true) }
  # =============================END Schema====================================

  def self.invalidate_expired_ones
    now = DateTime.now
    threads = Client.batch_size(500).map do |client|
      Thread.new(client) do |t_client|
        t_client.client_plans.map do |plan|
          if now >= plan.expired_date
            plan.update_attribute :status, false
            # rubocop:disable Metrics/LineLength
            Rails.logger.info "CLIENT: { id: #{t_client._id}, name: #{t_client.name} }\nPLAN(invalidated): #{plan.inspect}"
            # rubocop:enable Metrics/LineLength
          end
        end
      end
    end
    threads.map!(&:join)
  end
end
