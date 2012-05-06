class Cloudsdale.Models.Session extends Backbone.Model
  
  initialize: (attr) ->
    @set 'user', new Cloudsdale.Models.User(@get('user'))
    @set 'clouds', new Cloudsdale.Collections.Clouds(@get('user').get('clouds'))
    
  listenToCloud: (cloud) ->
    this
  
  # Returns true if the user is not a new user.
  isRegistered: -> !@get('user').get('isRegistered')
  
  # Returns true if user is affiliated with any clouds.
  hasClouds: -> @get('clouds').length > 1