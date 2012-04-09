class Cloudsdale.Models.User extends Backbone.Model
  
  url: -> "v1/users/#{@id}.json"