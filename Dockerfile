# =============================================================================
# Docker --name festinare_db
# -t="sescobb27/mongodb:v1"
# -p 27017
# -p 28017
# -d
FROM mongo:3.0
MAINTAINER Simon Escobar B <sescobb27@gmail.com>
# http://alexborisov.org/mongodb-security-and-user-access-control/
ENV MONGODB_ROOT_PASSWORD=""
ENV MONGODB_ADMIN_PASSWORD=""
ENV MONGODB_DB_ADMIN_PASSWORD=""
ENV MONGODB_DB_USERNAME=""
ENV MONGODB_DB_PASSWORD=""
EXPOSE 28017
COPY mongod.conf /etc/mongod.conf
CMD ["mongod"]
# docker build --file Dockerfile.mongo --tag="sescobb27/mongodb:v1" .
# docker run --tty -p 27017 -p 28017 -d --name="festinare_db" {ID}


# =============================================================================
# Docker --name festinare_cache
# -t="sescobb27/redis:v1"
# -d
FROM redis:3.0
MAINTAINER Simon Escobar B <sescobb27@gmail.com>
# RUN sysctl -w net.core.somaxconn=1024
# RUN sysctl vm.overcommit_memory=1
EXPOSE 6379
# docker build --file Dockerfile.redis --tag="sescobb27/redis:v1" .
# docker run --tty -p 6379 -d --name="festinare_cache" {ID}


# =============================================================================
# Docker --name festinare_nginx
# -t="sescobb27/nginx:v1"
# -p 80:80
# -d
FROM nginx:1.7
MAINTAINER Simon Escobar B <sescobb27@gmail.com>
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80 443
COPY festinare.conf /etc/nginx/sites-available/festinare.co
COPY festinare.conf /etc/nginx/sites-enabled/festinare.co
CMD ["nginx", "-g", "daemon off;"]
# docker build --file Dockerfile.nginx --tag="sescobb27/nginx:v1" .
# docker run --tty -p 8080:80 -d --name="festinare_nginx" {ID}


# =============================================================================
# Docker --name festinare_app
# -t="sescobb27/app:v1"
# -p 8080
# -d
FROM ruby:2.2.2-wheezy
MAINTAINER Simon Escobar B <sescobb27@gmail.com>

RUN apt-get update -qq && apt-get install -y build-essential

RUN curl -SLO "http://nodejs.org/dist/v0.10.0/node-v0.10.0-linux-x64.tar.gz" \
  && tar -xzf node-v0.10.0-linux-x64.tar.gz -C /usr/local --strip-components=1 \
  && rm "node-v0.10.0-linux-x64.tar.gz" \
  && npm install -g npm@2.7.3 \
  && npm cache clear

COPY . "$HOME/festinare"
WORKDIR "$HOME/festinare"

RUN npm install -g bower
RUN npm install -g grunt-cli
RUN bower install --allow-root # docker ALWAYS runs as root
RUN npm install


ENV RAILS_ENV="production"
ENV WEB_CONCURRENCY="8"
ENV PUMA_MAX_THREADS="32"
ENV PUMA_MIN_THREADS="16"
ENV MONGODB_DB_USERNAME=""
ENV MONGODB_DB_PASSWORD=""
ENV PORT=8080
ENV RACK_ENV="production"
ENV GCM_API_KEY=""
ENV MANDRILL_USERNAME=""
ENV MANDRILL_API_KEY=""
ENV SECRET_KEY_BASE="5b76aca614fec1de4e1929eda5c08892c44341d100401789b051b4a8c6156f8fcd4e68df96032f7d8a418b131ca61b773e8532632320535d3dbc3064fc42c83d"

ENV RAILS_VERSION 4.2.0

RUN gem install rails --version "$RAILS_VERSION"
RUN bundle install
# RUN rake db:mongoid:create_indexes
RUN grunt build
CMD ["bundle", "exec", "puma", "-d", "-C", "config/puma.rb"]
# docker build --file Dockerfile.rails --tag="sescobb27/app:v1" .
# docker run --tty -p 8080 -d --name="festinare_app" {ID}
