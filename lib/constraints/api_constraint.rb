module ApiConstraint
  class ApiVersionConstraint
    attr_reader :version, :default
    def initialize(options = {})
      @version = options[:version]
      @default = options[:default]
    end

    def matches?(request)
      @default || request.headers['Accept']
        .include?("application/vnd.festinare.v#{@version}")
    end
  end
end
