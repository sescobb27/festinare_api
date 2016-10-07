module ClientService
  # Invalidate Expired Client's Plans
  def self.invalidate!
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


  # Returns a newly created Client's Plan
  # @param client [Client] an already created Client object
  # @param plan [Plan] an already created Plan object
  # @return [ClientsPlan]
  def self.create_from_plan(client, plan)
    # the purchased plan is going to expire depending on the plan specifications
    # so for example:
    # DateTime.now => Thu, 12 Mar 2015 21:17:33 -0500
    # plan => {
    #             :currency => "COP",
    #           :deleted_at => nil,
    #          :description => "15% de ahorro",
    #         :expired_rate => 1,
    #         :expired_time => "month",
    #                 :name => "Hurry Up!",
    #     :num_of_discounts => 15,
    #                :price => 127500,
    #               :status => true
    # }
    # the purchased_plan.expired_date = Thu, 12 Apr 2015 21:17:33 -0500
    # 1 month after today
    ClientsPlan.new(
      plan_id: plan.id,
      client_id: client.id,
      expired_date: Time.zone.now + plan.expired_rate.send(plan.expired_time),
      num_of_discounts_left: plan.num_of_discounts
    ).tap do |clients_plan|
      yield clients_plan if block_given?
      clients_plan.save
    end
  end
end
