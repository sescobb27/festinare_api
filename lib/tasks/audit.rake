require 'bundler/audit/task'
Bundler::Audit::Task.new

namespace :audit do
  task default: 'bundle:audit'
end
