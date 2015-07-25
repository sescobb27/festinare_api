require 'auth_token'

module AuthHelper
  def jwt_validate_token(user)
    allow(JWT::AuthToken).to(
      receive(:validate_token).and_return(
        _id: user[:id],
        username: user[:username],
        email: user[:email]
      )
    )
  end

  def mock_token
    allow(JWT::AuthToken).to receive(:make_token).and_return('mysecretkey')
  end
end

# allow(JWT::AuthToken).to receive(:make_token).and_return('mysecretkey')
# expect(JWT::AuthToken.make_token({}, 3600)).to eq('mysecretkey')
