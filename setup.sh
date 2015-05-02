#!/bin/bash

rake db:mongoid:create_indexes
rake db:seed

whenever -w
bundle exec puma -C config/puma.rb
