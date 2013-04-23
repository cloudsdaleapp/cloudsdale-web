# ![CloudsdaleApp](https://secure.gravatar.com/avatar/006b4dec507eaac9967970a1cd967167?s=64) Cloudsdale

**********************************

Cloudsdale is a realtime chat application for the Web, iOS, Android and Windows Phone, primarily designed for bronies.

## Introduction
Cloudsdale is built with *Ruby on Rails* backed by *Redis*, *MongoDB*, *MemCached*, *RabbitMQ* and *Sidekiq (Celluloid)*. Cloudsdale is developed and tested on ruby MRI version *1.9.3*.

## Server Operations
The examples below require:
* You to have access to a Unix terminal with bash.
* You also need to have your SSH keys deployed.
* You have ruby 1.9.3 installed.

**Deploy from `master` on GitHub:**

```bash
bundle exec cap deploy
```

**Restart web servers on all servers:**

```bash
bundle exec cap deploy restart
```