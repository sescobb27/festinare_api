module ApiConstraint
  class ApiVersionConstraint
    attr_reader :version, :default
    def initialize options = {}
      @version = options[:version]
      @default = options[:default]
    end

    def matches? request
      @default || request.headers['Accept'].include?("application/vnd.hurryupdiscount.v#{@version}")
    end
  end

  class ApiSubdomainConstraint
    attr_reader :subdomain
    def initialize options = {}
      @subdomain = options[:subdomain]
    end

    def matches? request
      Rails.env == 'development' || request.subdomain == @subdomain
    end
  end
end
