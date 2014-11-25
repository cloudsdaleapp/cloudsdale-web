#!/bin/sh

set -e

APP_HOME=${APP_HOME:-.}
CONFIG_FILE=$APP_HOME/config/application.yml

echo "Step 1: Setting up configuration"
if [ -f $CONFIG_FILE ]; then
  echo "---> $CONFIG_FILE already exists"
else
  cp $CONFIG_FILE.example $CONFIG_FILE
  echo "---> $CONFIG_FILE copied from example"
fi

echo "Step 2: Installing dependencies"
if [ -x "$(which bundle)" ]; then
  echo "---> $(which bundle) already exists"
else
  gem install --quiet bundle
  echo "---> installed bundler at $(which bundle)"
fi
echo "---> bundling ruby gems"
bundle install --quiet

if [ $RAILS_ENV = "test" ]; then
  echo "Step 3: Running tests"
elif [ $RAILS_ENV = "development" ]; then
  echo "Step 3: Preparing database"
  bundle exec rake db:create db:migrate db:create_indexes
  echo "Step 4: Running application"
fi

cd $APP_HOME
exec "$@"