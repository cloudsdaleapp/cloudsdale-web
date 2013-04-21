mail:   mailcatcher -f
mongo:  mongod --port 52331 --dbpath ./db/data/mongodb/
queue:  rabbitmq-server
cache:  memcached
worker: bundle exec sidekiq -q high,10 -q medium,5 -q default,5 -q low,1 -v -e development -p tmp/pids/sidekiq.pid
