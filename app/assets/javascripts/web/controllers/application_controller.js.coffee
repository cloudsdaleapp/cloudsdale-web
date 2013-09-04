Cloudsdale.ApplicationController = Ember.Controller.extend
  title: 'Cloudsdale'

  user: ( () ->
    return @get('model').get('user')
  ).property('model.user')

  conversations: ( () ->
    return @get('model').get('conversations')
  ).property('model.conversations')

