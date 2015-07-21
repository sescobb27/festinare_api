class Customer < User
  # =============================relationships=================================
  embeds_one :mobile
  has_many :reviews
  # =============================END relationships=============================

  # =============================Schema========================================
  # each time a customer likes a discount, the discount's client id is added here
  field :client_ids, type: Array, default: []
  field :fullname
  # =============================END Schema====================================

  # =============================Schema Validations============================
  validates :fullname, presence: true
  # =============================END Schema Validations========================

  def self.send_notifications
    gcm = Gcm::Notification.instance
    # For sending between 1 or more devices (up to 1000). When you send a message to
    # multiple registration IDs, that is called a multicast message.
    registration_ids = []
    options = {
      collapse_key: 'new_discounts',
      # Test server.
      dry_run: (Rails.env.development? || Rails.env.test?)
    }
    customers_num = Customer.exists(mobile: true).count
    batch_size = 1000
    iterations = customers_num.fdiv(batch_size).ceil

    categories = Discount.discount_categories
    response = nil

    iterations.times do |x|
      customers = Customer.only(:_id, :categories, :mobile)
                  .in('categories.name' => categories)
                  .limit(batch_size)
                  .offset(batch_size * x)
      notify_customers = customers.select(&:mobile)
      next if notify_customers.empty?
      registration_ids.concat notify_customers.map(&:mobile).map(&:token)
      response = gcm.send_notification(registration_ids, options)
      registration_ids.clear
      Rails.logger.info <<-EOF
{ "action": "send_notification", "categories": "#{categories}", "gcm_response": "#{response}" }
EOF
    end
  end
end
