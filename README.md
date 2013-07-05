# ![CloudsdaleApp](https://secure.gravatar.com/avatar/006b4dec507eaac9967970a1cd967167?s=22) Cloudsdale

Cloudsdale is a realtime chat application for the Web, iOS, Android and Windows Phone, primarily designed for bronies.

***********************************
![Cloudsdale Interface](http://puu.sh/3pPMn.png)
***********************************

## Introduction
Cloudsdale is built with *Ruby on Rails* backed by *Redis*, *MongoDB*, *MemCached*, *RabbitMQ* and *Sidekiq (Celluloid)*. Cloudsdale is developed and tested on ruby MRI version *2.0.0*.

## Server Operations
The examples below require:
* You to have access to a Unix terminal with bash.
* You also need to have your SSH keys deployed.
* You have ruby 2.0.0 installed.

**Deploy from `master` on GitHub:**

```bash
bundle exec cap deploy
```

**Restart web servers on all servers:**

```bash
bundle exec cap deploy restart
```

**Create indexes**
```bash
bundle exec rake db:create_indexes
```

**Start the production Console**

To access the console you must first have a ssh enabled unix user on the server.
Then you can write these commands to enter the ruby pry REPL in production mode.
```bash
ssh {username}@cloudsdale.org
cd /opt/app/cloudsdale-web/current && bundle exec rails c production
```
