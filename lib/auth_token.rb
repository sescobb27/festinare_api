require 'jwt'
module JWT
  class AuthToken
    def self.make_token payload, time
      JWT.encode(payload, @private_key, algorithm: 'RS256', exp: time)
    end

    def self.validate_token token
      begin
        payload, header = JWT.decode(token, @public_key, algorithm: 'RS256')
        payload
      rescue
        nil
      end
    end

    private
      @private_key = Rails.application.config.PRIVATE_KEY
      @public_key = Rails.application.config.PUBLIC_KEY
  end
end
