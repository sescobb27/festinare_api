require 'auth_token'

module AuthHelper
  def jwt_validate_token(user)
    allow(JWT::AuthToken).to(
      receive(:validate_token).and_return(
        _id: user[:_id],
        username: user[:username],
        email: user[:email]
      )
    )
  end
end
