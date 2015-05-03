class User
  include Mongoid::Document
  # rubocop:disable Metrics/LineLength
  # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # when you don't want documents to actually get deleted from the database,
  # but "flagged" as deleted. Mongoid provides a Paranoia module to give you
  # just that.
  # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # person.delete   # Sets the deleted_at field to the current time, ignoring callbacks.
  # person.delete!  # Permanently deletes the document, ignoring callbacks.
  # person.destroy  # Sets the deleted_at field to the current time, firing callbacks.
  # person.destroy! # Permanently deletes the document, firing callbacks.
  # person.restore  # Brings the "deleted" document back to life.
  # person.restore(:recursive => true) # Brings "deleted" associated documents back to life recursively
  # rubocop:enable Metrics/LineLength
  include Mongoid::Paranoia
  include Mongoid::Timestamps::Created
  # =============================relationships=================================
  embeds_many :locations, as: :localizable
  embeds_many :discounts, as: :discountable
  embeds_many :categories, as: :categorizable
  embeds_one :mobile
  # =============================END relationships=============================

  # =============================Schema========================================
  # rubocop:disable Metrics/LineLength
  # Database Authenticatable: this module responsible for encrypting password and validating authenticity of a user while signing in.
  # Registerable: handles signing up users through a registration process, also allowing them to edit and destroy their account.
  # Recoverable: resets the user password and sends reset instructions.
  # Validatable: provides validations of email and password.
  # Omniauthable: adds Omniauth support.
  # Confirmable: sends emails with confirmation instructions and verifies whether an account is already confirmed during sign in.
  # rubocop:enable Metrics/LineLength
  devise :database_authenticatable,
         :registerable,
         :validatable,
         :recoverable
         # :confirmable https://github.com/plataformatec/devise/issues/3505
         # https://github.com/puma/puma/issues/647
  ## Database authenticatable
  field :email
  field :encrypted_password

  ## Confirmable
  field :confirmation_token
  field :confirmed_at, type: Time
  field :confirmation_sent_at, type: Time

  ## Recoverable
  field :reset_password_token
  field :reset_password_sent_at, type: Time

  field :username
  field :lastname
  field :name
  field :token

  index({ username: 1 }, unique: true)
  index({ email: 1 }, unique: true)
  index({ 'categories.name' => 1 }, unique: true, sparse: true)
  index({ token: 1 }, unique: true, sparse: true)
  # index({ confirmation_token: 1 }, unique: true)
  # =============================END Schema====================================

  # =============================Schema Validations============================
  # validates_presence_of :email,
  #                       :encrypted_password,
  #                       :username,
  #                       :lastname,
  #                       :name
  # =============================END Schema Validations========================

  before_validation :downcase_credentials

  def downcase_credentials
    self.username = self.username.downcase
    self.email = self.email.downcase
  end

  def self.send_notifications
    gcm = Gcm::Notification.instance
    # rubocop:disable Metrics/LineLength
    # For sending between 1 or more devices (up to 1000). When you send a message to
    # multiple registration IDs, that is called a multicast message.
    # rubocop:enable Metrics/LineLength
    registration_ids = []
    options = {
      collapse_key: 'new_discounts',
      # Test server.
      dry_run: (Rails.env == 'development' || Rails.env == 'test')
    }
    users_num = User.exists(mobile: true).count
    batch_size = 1000
    iterations = users_num.fdiv(batch_size).ceil

    categories = Discount.get_categories_from_discounts

    iterations.times do |x|
      users = User.only(:_id, :categories, :mobile)
              .limit(batch_size)
              .offset(batch_size * x)
      notify_users = users.select do |user|
        !(user.categories.map(&:name) & categories).empty? && user.mobile
      end
      next if notify_users.empty?
      registration_ids.concat notify_users.map(&:mobile).map(&:token)
      if registration_ids.length <= 1000
        response = gcm.send_notification(registration_ids, options)
        registration_ids.clear
        awesome_print 'GCM RESPONSE:'
        awesome_print response
      elsif registration_ids.length > 1000
        response = gcm.send_notification(registration_ids[0...1000], options)
        awesome_print 'GCM RESPONSE:'
        awesome_print response
        registration_ids = registration_ids[1000..-1]
      end
    end
  end
end
