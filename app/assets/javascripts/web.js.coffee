#= require jquery-2.0.3.min.js
#= require foundation
#= require handlebars
#= require ember
#= require ember-data
#= require_self
#
#= require ./web/cloudsdale
window.Cloudsdale = Ember.Application.create

  rootElement: 'body'

  LOG_TRANSITIONS: true
  LOG_TRANSITIONS_INTERNAL: true

  ready: -> $(document).foundation()

