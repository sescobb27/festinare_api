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

# =============================================================================
# Docker --name festinare_cache
# -t="sescobb27/redis:v1"
# -d
FROM redis:3.0
MAINTAINER Simon Escobar B <sescobb27@gmail.com>
COPY redis.conf /usr/local/etc/redis/redis.conf
RUN sysctl -w net.core.somaxconn=1024
RUN sysctl vm.overcommit_memory=1
EXPOSE 6379
CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]


# =============================================================================
# Docker --name festinare_nginx
# -t="sescobb27/nginx:v1"
# -p 80:80
# -d
FROM nginx:1.7
MAINTAINER Simon Escobar B <sescobb27@gmail.com>
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80 443
RUN rm /etc/nginx/conf.d/sites-enabled/default
COPY festinare.conf /etc/nginx/sites-available/festinare.com.co
RUN ln -s /etc/nginx/sites-available/festinare.com.co /etc/nginx/sites-enabled/festinare.com.co
CMD ["nginx", "-g", "daemon off;"]

# =============================================================================
# Docker --name festinare_app
# -t="sescobb27/app:v1"
# -p 8080
# -d
FROM ruby:2.2.2-wheezy
MAINTAINER Simon Escobar B <sescobb27@gmail.com>

RUN apt-get update \
    && apt-get install -y nodejs --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

COPY . "$HOME/festinare"
WORKDIR /festinare

RUN npm install -g bower
RUN bower install

USER www-data

ENV RAILS_ENV="production"
ENV WEB_CONCURRENCY="$(nproc)"
ENV PUMA_MAX_THREADS=""
ENV PUMA_MIN_THREADS=""
ENV MONGODB_DB_USERNAME=""
ENV MONGODB_DB_PASSWORD=""
ENV PORT=8080
ENV RACK_ENV="production"
ENV GCM_API_KEY=""
ENV MANDRILL_USERNAME=""
ENV MANDRILL_API_KEY=""
ENV SECRET_KEY_BASE=""

ENV RAILS_VERSION 4.2.1

RUN gem install rails --version "$RAILS_VERSION"
RUN bundle install
RUN rake db:mongoid:create_indexes
CMD ["bundle", "exec", "puma", "-d", "-C", "config/puma.rb"]

# docker build
# docker run [OPTIONS] [IMAGE]
