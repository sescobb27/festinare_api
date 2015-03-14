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
    # embeds_many :types,     as: :typeable
    embeds_many :categories, as: :categorizable
    embeds_many :locations, as: :localizable
    embeds_many :discounts, as: :discountable
    embeds_many :client_plans
  # =============================END relationships=============================
  # =============================Schema========================================
  # Database Authenticatable: this module responsible for encrypting password and validating authenticity of a user while signing in.
  # Registerable: handles signing up users through a registration process, also allowing them to edit and destroy their account.
  # Recoverable: resets the user password and sends reset instructions.
  # Validatable: provides validations of email and password.
  # Omniauthable: adds Omniauth support.
  # Confirmable: sends emails with confirmation instructions and verifies whether an account is already confirmed during sign in.
    devise  :database_authenticatable,
            :registerable,
            :validatable,
            :recoverable
            # :confirmable
    ## Database authenticatable
    field :email
    field :encrypted_password

    ## Confirmable
    field :confirmation_token
    field :confirmed_at, type: DateTime
    field :confirmation_sent_at, type: DateTime
    field :unconfirmed_email

    ## Recoverable
    field :reset_password_token
    field :reset_password_sent_at, type: DateTime


    field :username
    field :name
    field :rate, type: Float, default: 0.0
    # field :num_of_places
    field :image_url
    field :addresses, type: Array

    index({ username: 1 }, { unique: true, name: 'client_username_index' })
    index({ email: 1 }, { unique: true, name: 'client_email_index' })
    index({ name: 1 }, { unique: true, name: 'client_name_index' })
  # =============================END Schema====================================

  def has_plan?
    now = DateTime.now
    return !self.client_plans.empty? && self.client_plans.one? { |plan| now < plan.expired_date }
  end

  def decrement_num_of_discounts_left!
    current_plan = self.client_plans.first
    if current_plan.num_of_discounts_left > 0
      current_plan.inc(num_of_discounts_left: -1)
    else
      current_plan.status = false
      self.save
      raise Plan::PlanDiscountsExhausted
    end
  end
end
