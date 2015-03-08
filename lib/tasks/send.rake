namespace :send do
  desc "Send GCM Notifications to our users about new discounts they would like"
  task notification: :environment do
    gcm = Gcm::Notification.instance
    # For sending to 1 or more devices (up to 1000). When you send a message to
    # multiple registration IDs, that is called a multicast message.
    registration_ids = []
    options = {
      collapse_key: 'new_discounts',
      dry_run: (Rails.env == 'development' || Rails.env == 'test') # Test server.
    }
    users_num = User.count
    batch_size = 1000
    iterations = users_num / batch_size

    iterations.times do |x|
      registration_ids = User.only(:_id, :mobile).limit(batch_size).offset(batch_size * x).map(&:mobile).map(&:token)
      response = gcm.send(registration_ids, options)
      awesome_print "GCM RESPONSE:"
      awesome_print response
    end
  end

end
