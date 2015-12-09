module User
  extend ActiveSupport::Concern
  # rubocop:disable Metrics/LineLength
  # Database Authenticatable: this module responsible for encrypting password and validating authenticity of a user while signing in.
  # Registerable: handles signing up users through a registration process, also allowing them to edit and destroy their account.
  # Recoverable: resets the user password and sends reset instructions.
  # Validatable: provides validations of email and password.
  # Omniauthable: adds Omniauth support.
  # Confirmable: sends emails with confirmation instructions and verifies whether an account is already confirmed during sign in.
  # rubocop:enable Metrics/LineLength
  included do
    # has_many :locations, as: :localizable
    devise :database_authenticatable,
           :registerable,
           :validatable,
           :recoverable,
           :confirmable
           # https://github.com/plataformatec/devise/issues/3505
           # https://github.com/puma/puma/issues/647
           # https://bugs.ruby-lang.org/issues/10871
    validates :username, presence: true
    before_validation :downcase_credentials

    def self.invalidate!
      self.find_each do |model|
        model.tokens.delete_if do |token|
          !JWT::AuthToken.validate_token(token)
        end
        model.save
      end
    end
  end
  CATEGORIES = ['Bar', 'Disco', 'Restaurant'].freeze
  # validates :category_name, inclusion: { in: CATEGORIES }

  def downcase_credentials
    self[:username] = self[:username] ? self[:username].downcase : ''
    self[:email] = self[:email] ? self[:email].downcase : ''
  end
  # # user.delete_from_array :tokens, 'JWT_TOKEN'
  # # => user.tokens.delete 'JWT_TOKEN'
  # # => user.tokens_will_change!
  # def delete_from_array(attr_name, value)
  #   self[attr_name].send :delete, value
  #   self.send "#{attr_name}_will_change!"
  # end
end
