#faye: bundle exec rackup ./lib/faye/faye.ru -s thin -E production -e 'ENVIRONMENT = :development'
faye: bundle exec ruby ./lib/faye/faye.rb development
mongo: rm ./db/data/mongodb/mongod.lock; mongod --port 52331 --dbpath ./db/data/mongodb/
search: elasticsearch -f