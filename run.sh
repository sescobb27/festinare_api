#!/bin/bash
docker run --tty -p 127.0.0.1:27017:27017 -p 127.0.0.1:28017:28017 -d --name="festinare_db" sescobb27/mongodb:v1
docker run --tty -p 127.0.0.1:6379:6379 -d --name="festinare_cache" sescobb27/redis:v1
docker run --tty -p 127.0.0.1::8080 -d --name="festinare_app" --link festinare_db:festinare_db --link festinare_cache:festinare_cache sescobb27/app:v1 ./setup.sh
docker run --tty -p 80:80 -p 443:443 -d --name="festinare_nginx" --link festinare_app:festinare_app sescobb27/nginx:v1
