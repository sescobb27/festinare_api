module Gcm
  class Notification
    class << self
      def instance
        GCM.new(ENV['GCM_API_KEY'])
      end
    end
  end
end
