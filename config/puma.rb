require 'dotenv'
ENV.update Dotenv::Environment.new(File.expand_path('.env.production'))

# bundle exec puma -p $PORT -C config/puma.rb
workers Integer(ENV['WEB_CONCURRENCY'] || 2)
min_threads_count = Integer(ENV['PUMA_MIN_THREADS'] || 0)
max_threads_count = Integer(ENV['PUMA_MAX_THREADS'] || 16)
threads min_threads_count, max_threads_count

pidfile 'tmp/pids/puma.pid'
state_path 'log/puma.state'

env_port = ENV['PORT'] && ENV['PORT'] != ''
port(env_port ? ENV['PORT'] : 3_000)
current_env = ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'
environment current_env

on_worker_boot do
  ENV.update Dotenv::Environment.new(File.expand_path('.env.production'))
  Mongoid.load!(File.expand_path('../mongoid.yml', __FILE__), current_env)
end

preload_app!
