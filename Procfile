# faye: sh ./vendor/submodules/cloudsdale-faye/start.sh
mail: bundle exec mailcatcher -f
mongo: mongod --port 52331 --dbpath ./db/data/mongodb/
queue: rabbitmq-server
cache: memcached
workers: bundle exec sidekiq -C ./config/sidekiq.yml
