faye: ./vendor/faye/start.sh
mongo: mongod --port 52331 --dbpath ./db/data/mongodb/
queue: rabbitmq-server
message_worker: bundle exec ./lib/background/bin/worker start messages