# hurry-app-discount
rhc create-app hurryup ruby-2.0 mongodb-2.4
rhc env set RAILS_ENV="production" -a hurryup
rhc env set OPENSHIFT_RUBY_SERVER=puma -a hurryup
git remote add openshift ssh://54e8b57dfcf9332b8d000082@hurryup-sudoapps.rhcloud.com/~/git/hurryup.git
