faye: rackup ./lib/faye/faye.ru -s thin -E production -e 'ENVIRONMENT = :development'
mongo: rm ./db/data/mongodb/mongod.lock; mongod --port 52331 --dbpath ./db/data/mongodb/
search: elasticsearch -f