require 'dotenv'

# bundle exec puma -C config/puma.rb
ENV.update Dotenv::Environment.new('.env')
workers Integer(ENV['WEB_CONCURRENCY'] || 2)
min_threads_count = Integer(ENV['PUMA_MIN_THREADS'] || 0)
max_threads_count = Integer(ENV['PUMA_MAX_THREADS'] || 16)
threads min_threads_count, max_threads_count

pidfile 'tmp/pids/puma.pid'
state_path 'log/puma.state'

preload_app!

rackup DefaultRackup
port ENV['PORT'] || 3_000
environment ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'

on_worker_boot do
  ENV.update Dotenv::Environment.new('.env')
  Mongoid.load!(File.expand_path('../mongoid.yml', __FILE__), :production)
end
