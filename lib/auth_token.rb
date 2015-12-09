require 'jwt'
module JWT
  class AuthToken
    class << self
      def make_token(payload, time)
        JWT.encode(payload.merge(exp: time), private_key, algorithm: 'RS256', exp: time)
      end

      def validate_token(token)
        payload, _ = JWT.decode(token, public_key, algorithm: 'RS256')
        payload
      rescue
        nil
      end

      private

        def private_key
          Rails.application.config.PRIVATE_KEY
        end

        def public_key
          Rails.application.config.PUBLIC_KEY
        end
    end
  end
end
