# hurry-app-discount

commands

rake invalidate:discounts
rake invalidate:plans

rake db:mongoid:create_indexes
rake db:seed
whenever -w

bundle exec puma -C config/puma.rb


zeus s -b 0.0.0.0 -p 8080
zeus start
zeus rspec

sudo cp festinare.conf /etc/nginx/sites-available/festinare.com.co && sudo service nginx restart && sudo nginx -t


TODO

/clients
/clients/id/password update
/clients/id/address update/delete
/clients/id/categories update/delete

users can't review a client more than one time.
users auth
/users/id/categories update/delete
/users/id/locations create
/users/id/password update
/users/id/mobile add/delete

/discounts/client_id create

/discounts to be /clients, just because discounts are embedded in clients, so
we need to retrieve clients with their discounts

refactor tests
