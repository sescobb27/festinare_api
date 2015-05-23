class Client
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
  embeds_many :categories, as: :categorizable
  embeds_many :locations, as: :localizable
  embeds_many :discounts, as: :discountable
  embeds_many :client_plans
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
         :recoverable,
         :confirmable
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
  field :name
  field :rates, type: Array
  field :avg_rate, type: Float, default: 0.0
  # field :num_of_places
  field :image_url
  field :addresses, type: Array
  field :token, type: Array
  field :feedback, type: Array

  index({ username: 1 }, unique: true)
  index({ email: 1 }, unique: true)
  index({ name: 1 }, unique: true)
  index({ confirmation_token: 1 }, unique: true)
  index({ 'categories.name' => 1 }, unique: true, sparse: true)
  index({ discounts: 1 }, unique: false)
  index({ token: 1 }, unique: true, sparse: true)

  scope :has_active_discounts, -> { where('discounts.status' => true) }
  # =============================END Schema====================================

  # =============================Schema Validations============================
  validates_presence_of :username, :name, :encrypted_password
  # =============================END Schema Validations========================
  before_validation :downcase_credentials

  def downcase_credentials
    self[:username] = self[:username].downcase
    self[:email] = self[:email].downcase
  end

  def plan?
    now = Time.zone.now
    !self.client_plans.with_discounts.empty? && self.client_plans.with_discounts.one? do |plan|
      now < plan.expired_date
    end
  end

  def decrement_num_of_discounts_left!
    if self.client_plans.with_discounts.empty?
      raise Plan::PlanDiscountsExhausted
    else
      self.client_plans.with_discounts.first.inc num_of_discounts_left: -1
    end
  end

  def unexpired_discounts(time)
    Thread.current[:client] = self
    Thread.current[:client].discounts = self.discounts.select do |discount|
      time < discount.expire_time
    end
  end

  def self.available_discounts(categories)
    query = Client.has_active_discounts
    query.in('categories.name' => categories) unless categories.empty?
    now = Time.zone.now
    threads = query.batch_size(500).map do |client|
      Thread.new(client) do |t_client|
        t_client.unexpired_discounts(now)
      end
    end

    threads.map do |thread|
      thread.join
      thread[:client]
    end
  end
end
