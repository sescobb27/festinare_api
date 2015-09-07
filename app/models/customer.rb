# == Schema Information
#
# Table name: customers
#
#  id                     :integer          not null, primary key
#  fullname               :string(100)      not null
#  categories             :string           default([]), is an Array
#  tokens                 :string           default([]), is an Array
#  username               :string(100)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  email                  :string(100)      not null
#  encrypted_password     :string           not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#

# @author Simon Escobar
class Customer < ActiveRecord::Base
  include User
  # =============================relationships=================================
  has_many :mobiles, inverse_of: :customer
  has_many :customers_discounts
  has_many :discounts, through: :customers_discounts
  has_many :locations, inverse_of: :customer
  # =============================END relationships=============================

  # =============================Schema========================================
  # =============================END Schema====================================

  # =============================Schema Validations============================
  validates :fullname, presence: true
  # =============================END Schema Validations========================

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
