Cloudsdale.ApplicationController = Ember.Controller.extend
  title: 'Cloudsdale'

  hasConversations: ( () ->
    @get('model').get('conversations').get('length') > 0
  ).property('model.conversations.length')

