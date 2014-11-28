#!/bin/sh

set -e

APPNAME=${APPNAME:-cloudsdale-web}
APPHOME=${APPHOME:-.}

CONFIG_FILE=$APPHOME/config/application.yml

echo " ---> setting up configuration"
if [ -f $CONFIG_FILE ]; then
  echo " ---> $CONFIG_FILE already exists"
else
  cp $CONFIG_FILE.example $CONFIG_FILE
  echo " ---> $CONFIG_FILE copied from example"
fi

echo " ---> installing dependencies"
if [ -x "$(which bundle)" ]; then
  echo " ---> $(which bundle) already exists"
else
  gem install --quiet bundle
  echo " ---> installed bundler at $(which bundle)"
fi
echo " ---> bundling ruby gems"
bundle install --quiet

if [ $RAILS_ENV = "test" ]; then
  echo " ---> running tests"
else
  if [ $RAILS_ENV = "development" ]; then
    echo " ---> preparing database"
    bundle exec rake db:create db:migrate db:create_indexes
  fi
  echo " ---> running application"
fi

exec "$@"