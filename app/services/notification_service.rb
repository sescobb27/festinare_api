module NotificationService
  def self.send_notifications
    gcm = Gcm::Notification.instance
    options = {
      collapse_key: 'new_discounts',
      # Test server.
      dry_run: (Rails.env.development? || Rails.env.test?)
    }
    categories = Discount.categories
    # ==========================================================================
    # SELECT "customers".*
    # FROM "customers"
    # WHERE (categories <@ ARRAY[NULL]::varchar[...])
    # ==========================================================================
    Customer.where('categories <@ ARRAY[?]::varchar[]', categories)
      .joins(:mobiles)
      .where(mobiles: { enabled: true }).find_in_batches do |customers|
        next if customers.empty?
        # For sending between 1 or more devices (up to 1000). When you send a message to
        # multiple registration IDs (tokens), that is called a multicast message.
        tokens = customers.map(&:mobiles).map do |mobiles|
          mobiles.map(&:token)
        end
        response = gcm.send_notification(tokens, options)
        Rails.logger.info <<-EOF
{ "action": "send_notification", "categories": "#{categories}", "gcm_response": "#{response}" }
EOF
    end
  end
end
