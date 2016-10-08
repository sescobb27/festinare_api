module ClientsPlanService
  # Invalidate Expired Client's Plans
  def self.invalidate_expired_plans!
    now = Time.zone.now
    # ==========================================================================
    # SELECT "clients".*
    # FROM "clients"
    # INNER JOIN "clients_plans"
    # ON "clients_plans"."client_id" = "clients"."id"
    # WHERE "clients_plans"."status" = 't'
    # ==========================================================================
    Client.joins(:clients_plans)
      .where(clients_plans: { status: true })
      .find_each do |client|
      client.clients_plans.map do |plan|
        next if now < plan.expired_date
        plan.update status: false
        Rails.logger.info <<-EOF
{ "action": "invalidate_plan", "id": "#{client.id}", "name": "#{client.name}", "plan": "#{plan.attributes}" }
EOF
      end
    end
  end
end
