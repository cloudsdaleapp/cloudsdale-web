class Cloudsdale.Models.Session extends Backbone.Model
  
  initialize: (attr) ->
    @set 'user', new Cloudsdale.Models.User(@get('user'))
    @set 'clouds', new Cloudsdale.Collections.Clouds(@get('clouds'))
  
  listenToCloud: (cloud) ->
    this
    