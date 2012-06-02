faye: ./vendor/faye/start.sh
mongo: mongod --port 52331 --dbpath ./db/data/mongodb/
queue: rabbitmq-server
faye_worker: env RAILS_ENV=development bundle exec ./lib/background/bin/worker start faye