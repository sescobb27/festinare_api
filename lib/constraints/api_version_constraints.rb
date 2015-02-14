class ApiVersionConstraint
  attr_reader :version, :default
  def initialize options
    @version = options[:version]
    @default = options[:default]
  end

  def match? request
    @default || request.headers['Accept'].include?("application/vnd.ciudadgourmet.v#{@version}")
  end
end
