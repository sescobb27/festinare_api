module Gcm
  class Notification
    class << self
      def instance
        @gcm ||= GCM.new(ENV['GCM_API_KEY'])
      end
    end
  end
end
