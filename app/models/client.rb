class Client
  include Mongoid::Document
  # =============================relationships=================================
    # embeds_many :types,     as: :typeable
    has_many :types, as: :typeable
    embeds_many :locations, as: :localizable
    embeds_many :discounts, as: :discountable
    has_and_belongs_to_many :plans
  # =============================END relationships=============================
  # =============================Schema========================================
    field :username
    field :email
    field :encrypted_password
    field :name
    field :created_at, type: DateTime
    field :rate, type: Float, default: 0.0
    # field :num_of_places
    field :image_url
    field :addresses, type: Array
    field :addresses_locations, type: Array

    index({ username: 1 }, { unique: true, name: 'client_username_index' })
    index({ email: 1 }, { unique: true, name: 'client_email_index' })
    index({ name: 1 }, { unique: true, name: 'client_name_index' })
  # =============================END Schema====================================
end
