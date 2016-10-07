module DiscountService
  def self.categories
    # ==========================================================================
    # SELECT DISTINCT UNNEST(categories)
    # FROM "clients"
    # LEFT OUTER JOIN "discounts"
    # ON "discounts"."client_id" = "clients"."id"
    # WHERE "discounts"."status" = $1
    # AND ("discounts"."created_at" < (now() + ("discounts"."duration" * 60 || 'seconds')::interval))  [["status", "t"]]
    # ==========================================================================
    Client.select('UNNEST(categories)')
      .distinct
      .with_active_discounts
      .merge(Discount.not_expired)
      .pluck('UNNEST(categories)')
  end

  # Invalidate Expired Discounts
  def self.invalidate!
    now = Time.zone.now
    # ==========================================================================
    # SELECT "clients"."*", "discounts"."*"
    # FROM "clients"
    # LEFT OUTER JOIN "discounts"
    # ON "discounts"."client_id" = "clients"."id"
    # WHERE "discounts"."status" = 't'
    # ==========================================================================
    Client.with_active_discounts.find_each do |client|
      client.discounts.map do |discount|
        next unless discount.expired? now
        discount.update status: false
        # rubocop:disable Metrics/LineLength
        Rails.logger.info <<-EOF
{ "action": "invalidate_discount", "id": "#{client.id}", "name": "#{client.name}", "discount": "#{discount.attributes}" }
EOF
        # rubocop:enable Metrics/LineLength
      end
    end
  end

  # Returns all available discounts given a set of categories and filters
  # @param opts [Hash] valid options are = { omit: [Fixnum] limit: Fixnum offset: Fixnum }
  # @return [Array<Discount>]
  def self.available(categories = [], opts = {})
    query = Discount.joins(:client).where(discounts: { status: true })
    query.where(':categories = ANY ("client"."categories")', categories: categories) unless categories.empty?
    query.where.not(discounts: { id: opts[:omit] }) if opts[:omit]
    now = Time.zone.now

    query.limit(opts[:limit]).offset(opts[:offset]).to_a.select do |discount|
      !discount.expired? now
    end
  end
end
