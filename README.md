# hurry-app-discount

## Commands

```bash
# Festinare Tasks
rake invalidate:discounts
rake invalidate:plans

# Festinare DB Tasks
rake db:create
rake db:migrate
rake db:seed

# Parallel tests
RAILS_ENV=test rake parallel:create
RAILS_ENV=test rake parallel:prepare
rake parallel:spec

# Tests
rspec

# Cron Jobs
whenever -w

# Start Puma Server
bundle exec puma -C config/puma.rb

# Zeus preloader (optional)
zeus s -b 0.0.0.0 -p 8080
zeus start
zeus rspec

# Nginx
sudo cp festinare.conf /etc/nginx/sites-available/festinare.com.co && sudo service nginx restart && sudo nginx -t
```

## TODO
/clients
/clients/id/password update
/clients/id/address update/delete

/users/id/locations create
/users/id/password update
/users/id/mobile add/delete

/discounts/client_id create

## API Endpoint

```
POST   /api/v1/customers/password                       api/v1/passwords#create {:format=>:json}
GET    /api/v1/customers/password/new                   api/v1/passwords#new {:format=>:json}
GET    /api/v1/customers/password/edit                  api/v1/passwords#edit {:format=>:json}
PATCH  /api/v1/customers/password                       api/v1/passwords#update {:format=>:json}
PUT    /api/v1/customers/password                       api/v1/passwords#update {:format=>:json}
POST   /api/v1/customers/confirmation                   api/v1/confirmations#create {:format=>:json}
GET    /api/v1/customers/confirmation/new               api/v1/confirmations#new {:format=>:json}
GET    /api/v1/customers/confirmation                   api/v1/confirmations#show {:format=>:json}
POST   /api/v1/clients/password                         api/v1/passwords#create {:format=>:json}
GET    /api/v1/clients/password/new                     api/v1/passwords#new {:format=>:json}
GET    /api/v1/clients/password/edit                    api/v1/passwords#edit {:format=>:json}
PATCH  /api/v1/clients/password                         api/v1/passwords#update {:format=>:json}
PUT    /api/v1/clients/password                         api/v1/passwords#update {:format=>:json}
POST   /api/v1/clients/confirmation                     api/v1/confirmations#create {:format=>:json}
GET    /api/v1/clients/confirmation/new                 api/v1/confirmations#new {:format=>:json}
GET    /api/v1/clients/confirmation                     api/v1/confirmations#show {:format=>:json}
POST   /api/v1/customers/login                          api/v1/customers#login {:format=>:json}
POST   /api/v1/customers/logout                         api/v1/customers#logout {:format=>:json}
GET    /api/v1/customers/me                             api/v1/customers#me {:format=>:json}
POST   /api/v1/customers/:id/like/discount/:discount_id api/v1/discounts#like {:format=>:json}
PUT    /api/v1/customers/:id/mobile                     api/v1/customers#mobile {:format=>:json}
GET    /api/v1/customers/:id/likes                      api/v1/customers#likes {:format=>:json}
PUT    /api/v1/customers/:id/categories                 api/v1/customers#add_category {:format=>:json}
DELETE /api/v1/customers/:id/categories                 api/v1/customers#delete_category {:format=>:json}
POST   /api/v1/customers/:customer_id/reviews           api/v1/reviews#create {:format=>:json}
PATCH  /api/v1/customers/:customer_id/reviews/:id       api/v1/reviews#update {:format=>:json}
PUT    /api/v1/customers/:customer_id/reviews/:id       api/v1/reviews#update {:format=>:json}
DELETE /api/v1/customers/:customer_id/reviews/:id       api/v1/reviews#destroy {:format=>:json}
POST   /api/v1/customers                                api/v1/customers#create {:format=>:json}
GET    /api/v1/customers/:id                            api/v1/customers#show {:format=>:json}
PATCH  /api/v1/customers/:id                            api/v1/customers#update {:format=>:json}
PUT    /api/v1/customers/:id                            api/v1/customers#update {:format=>:json}
DELETE /api/v1/customers/:id                            api/v1/customers#destroy {:format=>:json}
POST   /api/v1/clients/login                            api/v1/clients#login {:format=>:json}
POST   /api/v1/clients/logout                           api/v1/clients#logout {:format=>:json}
GET    /api/v1/clients/me                               api/v1/clients#me {:format=>:json}
PUT    /api/v1/clients/:id/categories                   api/v1/clients#add_category {:format=>:json}
DELETE /api/v1/clients/:id/categories                   api/v1/clients#delete_category {:format=>:json}
GET    /api/v1/clients/:client_id/discounts             api/v1/discounts#discounts {:format=>:json}
POST   /api/v1/clients/:client_id/discounts             api/v1/discounts#create {:format=>:json}
GET    /api/v1/clients                                  api/v1/clients#index {:format=>:json}
POST   /api/v1/clients                                  api/v1/clients#create {:format=>:json}
PATCH  /api/v1/clients/:id                              api/v1/clients#update {:format=>:json}
PUT    /api/v1/clients/:id                              api/v1/clients#update {:format=>:json}
DELETE /api/v1/clients/:id                              api/v1/clients#destroy {:format=>:json}
GET    /api/v1/reviews/:id                              api/v1/reviews#show {:format=>:json}
GET    /api/v1/discounts                                api/v1/discounts#index {:format=>:json}
POST   /api/v1/plans/:plan_id/purchase                  api/v1/plans#purchase_plan {:format=>:json}
GET    /api/v1/plans                                    api/v1/plans#index {:format=>:json}
```
