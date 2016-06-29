rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
current_env = ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'

resque_config = YAML.load_file("#{rails_root}/config/resque.yml")
Resque.redis = resque_config[current_env]
Resque.after_fork = -> { ActiveRecord::Base.establish_connection }
