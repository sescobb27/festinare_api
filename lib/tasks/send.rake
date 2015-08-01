namespace :send do
  desc 'Send GCM Notifications to our users about new discounts they would like'
  task notification: :environment do
    Customer.send_notifications
  end
end
