class Cloudsdale.Models.User extends Backbone.Model
  
  url: -> "/v1/users/#{@id}.json"
  
  defaults:
    name: ""
    avatar: {}
    email: ""
    time_zone: ""
    role: "normal"
    member_since: null
    invisible: false