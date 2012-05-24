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
  
  acceptTnc: (attr) ->
    attr ||= {}
    attr.url = "/v1/users/#{@id}/accept_tnc.json"
    return @save({},attr)
  
  removeAvatar: (options) ->
    attr = {}
    attr.remove_avatar = true
    return @save(attr,options)