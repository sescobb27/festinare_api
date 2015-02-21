# bundle exec puma -C config/puma.rb
workers Integer(ENV['WEB_CONCURRENCY'] || 2)
min_threads_count = Integer(ENV['PUMA_MIN_THREADS'] || 0)
max_threads_count = Integer(ENV['PUMA_MAX_THREADS'] || 16)
threads min_threads_count, max_threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

# on_worker_boot do
#   Worker specific setup for Rails 4.1+
#   See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
#   ActiveRecord::Base.establish_connection
# end
