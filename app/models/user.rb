class User
  include Mongoid::Document
  # =============================relationships=================================
    embeds_many :locations, as: :localizable
    embeds_many :likes, class_name: 'Discount' , as: :discountable
    has_many    :subscriptions, class_name: 'Category', as: :categorizable, autosave: true
  # =============================END relationships=============================

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise  :database_authenticatable,
          :registerable,
          :trackable,
          :validatable
  #         :recoverable,
  #         :rememberable,
  #         :confirmable

  # =============================Schema========================================
    ## Database authenticatable
    field :email
    field :encrypted_password

    ## Trackable
    field :sign_in_count, type: Integer, default: 0
    field :current_sign_in_at, type: DateTime
    field :last_sign_in_at, type: DateTime
    field :current_sign_in_ip
    field :last_sign_in_ip

    ## Confirmable
    field :confirmation_token
    field :confirmed_at, type: DateTime
    field :confirmation_sent_at, type: DateTime
    field :unconfirmed_email

    ## Recoverable
    field :reset_password_token
    field :reset_password_sent_at, type: DateTime

    ## Rememberable
    field :remember_created_at, type: DateTime

    field :username
    field :lastname
    field :name
    field :rate, type: Float
    field :created_at, type: DateTime
    field :updated_at, type: DateTime

    index({ username: 1 }, { unique: true, name: 'username_index' })
    index({ email: 1 }, { unique: true, name: 'email_index' })
  # =============================END Schema====================================

  # =============================User Schema Validations=======================
    validates_presence_of :email, :encrypted_password, :username, :lastname,
      :name
  # =============================END User Schema Validations===================

end
