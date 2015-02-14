class User
  include Mongoid::Document
  # =============================User relationship===========================


  # =============================END User relationship=======================

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise  :database_authenticatable,
          :registerable,
          :trackable,
          :validatable
  #         :recoverable,
  #         :rememberable,
  #         :confirmable

  # =============================User Schema=================================
  field "username"
  field "lastname"
  field "name"
  field "rate", type: Float
  field "email"
  field "encrypted_password"
  field "reset_password_token"
  field "reset_password_sent_at", type: DateTime
  field "remember_created_at", type: DateTime
  field "current_sign_in_at", type: DateTime
  field "last_sign_in_at", type: DateTime
  field "current_sign_in_ip"
  field "last_sign_in_ip"
  field "confirmation_token"
  field "confirmed_at", type: DateTime
  field "confirmation_sent_at", type: DateTime
  field "unconfirmed_email"
  field "created_at", type: DateTime
  field "updated_at", type: DateTime

  index username: 1, { unique: true, name: "username_index" }
  index email: 1, { unique: true, name: "email_index" }
end
