require 'dotenv'

current_env = ENV['RACK_ENV'] || ENV['RAILS_ENV']

throw 'Please set RACK_ENV or RAILS_ENV env variable' if current_env.nil? || current_env.empty?

ENV.update Dotenv::Environment.new(File.expand_path(".envrc.#{current_env}"))

# bundle exec puma -p $PORT -C config/puma.rb
workers Integer(ENV['WEB_CONCURRENCY'] || 2)
min_threads_count = Integer(ENV['PUMA_MIN_THREADS'] || 0)
max_threads_count = Integer(ENV['PUMA_MAX_THREADS'] || 16)
threads min_threads_count, max_threads_count

pidfile 'tmp/pids/puma.pid'
state_path 'log/puma.state'

port ENV['PORT'] || 3_000
environment current_env

on_worker_boot do
  ActiveRecord::Base.establish_connection
end

preload_app!
