source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0'

ruby '2.2.2'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  gem 'dotenv-rails', require: 'dotenv/rails-now'
  # rubocop:disable Metrics/LineLength
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  # rubocop:enable Metrics/LineLength
  gem 'byebug', '~> 4.0.0'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # rubocop:disable Metrics/LineLength
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # rubocop:enable Metrics/LineLength
  gem 'spring', '~> 1.3.0'
  gem 'bullet'
  gem 'mongoid-rspec', '~> 2.1.0'
  gem 'rspec-rails', '~> 3.2.0'
  gem 'factory_girl_rails', '~> 4.5.0'
  gem 'ffaker', '~> 2.0.0'
  gem 'shoulda-matchers'
  gem 'rb-readline'
  gem 'hirb'
  gem 'fancy_irb', '~> 1.0.0'
  gem 'awesome_print'
end

gem 'active_model_serializers', '~> 0.9.0'
# gem 'websocket-rails'
gem 'puma', '~> 2.11.0'
gem 'jwt-rb'
gem 'mongoid', '~> 4.0.1'
gem 'mongoid_paranoia', '~> 0.1.2'
# rubocop:disable Metrics/LineLength
# https://github.com/mongoid/moped/pull/359 => ConnectionPool::PoolShuttingDownError
# rubocop:enable Metrics/LineLength
gem 'moped', '2.0.4', github: 'wandenberg/moped', branch: 'operation_timeout'
gem 'devise'
gem 'bson_ext'
# Abort requests that are taking too long
gem 'rack-timeout', '~> 0.2.0'
gem 'hiredis'
gem 'redis'
gem 'whenever', require: false
gem 'gcm'
