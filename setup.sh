#!/bin/bash

rake db:seed

whenever -w
bundle exec puma -C config/puma.rb
