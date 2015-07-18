class Client
  include Mongoid::Document
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
  include Mongoid::Paranoia
  include Mongoid::Timestamps::Created
  # =============================relationships=================================
  embeds_many :categories, as: :categorizable
  embeds_many :locations, as: :localizable
  embeds_many :discounts, as: :discountable
  embeds_many :client_plans
  has_many :reviews
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
  # field :num_of_places
  field :image_url
  field :addresses, type: Array, default: []
  field :token, type: Array, default: []

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
  validates :username, :name, :encrypted_password, presence: true
  # =============================END Schema Validations========================
  before_validation :downcase_credentials

  def downcase_credentials
    self[:username] = self[:username].downcase
    self[:email] = self[:email].downcase
  end

  def plan?
    now = Time.zone.now
    !self.client_plans.with_discounts.empty? &&
      self.client_plans.with_discounts.one? do |plan|
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
    self.discounts.select { |discount| !discount.expired? time }
  end

  def add_category(name)
    self.categories.create name: name
  end

  def remove_category(name)
    self.pull(categories: { name: name })
  end

  def update_password(credentials)
    unless self.valid_password? credentials[:current_password]
      self.errors.add :password, 'Invalid'
      return false
    end

    self.password = credentials[:password]
    self.password_confirmation = credentials[:password_confirmation]

    self.save
  end

  def self.review_client(id, review)
    client = Client.find id
    client.push feedback: review[:feedback], rates: review[:rate].to_i
    client.set avg_rate: client.rates.sum.fdiv(client.rates.length)
  end

  def self.available_discounts(categories, opts)
    query = Client.has_active_discounts
    query.in('categories.name' => categories) unless categories.empty?
    now = Time.zone.now
    threads = []
    query.limit(opts[:limit]).offset(opts[:offset]).each do |client|
      threads << Thread.new(client) do |t_client|
        Thread.current[:client] = t_client
        break if t_client.discounts.empty?
        Thread.current[:client].discounts = t_client.unexpired_discounts(now)
      end
      threads.map!(&:join) if threads.length >= ENV['POOL_SIZE'].to_i
    end

    threads.map do |thread|
      thread.join
      thread[:client] unless thread[:client].discounts.empty?
    end.compact
  end
end
