sudo apt-get install -y build-essential libffi-dev git-core nodejs npm --no-install-recommends
git clone https://github.com/sescobb27/hurry-app-discount.git
sudo npm install -g bower
sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo mkdir -p /data/db
sudo service mongod start

wget http://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.0.tar.gz
tar xvzf ruby-2.2.0.tar.gz
cd ruby-2.2.0/
CFLAGS=-fPIC ./configure --enable-shared --disable-install-doc --disable-install-rdoc --disable-install-capi
make -j$(nproc)
sudo make install
cd ..
rm -rf ruby-2.2.0 ruby-2.2.0.tar.gz
echo "gem: --no-ri --no-rdoc" > ~/.gemrc
echo "export RAILS_ENV='production'" >> .bashrc
echo "export WEB_CONCURRENCY=\"$(nproc)\"" >> .bashrc
echo "export PUMA_MAX_THREADS=16" >> .bashrc
echo "export PUMA_MIN_THREADS=8" >> .bashrc
echo "export PORT=8080" >> .bashrc
echo "export RACK_ENV='production'" >> .bashrc
KEY=$(ruby -e "require 'securerandom'; puts SecureRandom.hex(64)")
echo "export SECRET_KEY_BASE=\"$KEY\"" >> .bashrc
source .bashrc

sudo gem install bundle
cd hurry-app-discount
bundle install
# RUBY
echo -e "production:\n  secret_key_base: <%= ENV[\"SECRET_KEY_BASE\"] %>" >> config/secrets.yml
bower install
bundle exec rake assets:precompile
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to 8080
bundle exec puma -C config/puma.rb
