class Cloudsdale.Models.User extends Backbone.Model
  
  url: -> "/v1/users/#{@id}.json"
  type: 'user'
  
  setters:
      
    clouds: (value) ->
      new Cloudsdale.Collections.Clouds value,
        url: -> "/v1/users/#{@id}/clouds.json"
  
  defaults:
    name: ""
    avatar: {}
    email: ""
    time_zone: ""
    role: "normal"
    member_since: null
    invisible: false
    is_transient: true
  
  acceptTnc: (attr) ->
    attr ||= {}
    attr.url = "/v1/users/#{@id}/accept_tnc.json"
    return @save({},attr)
  
  removeAvatar: (options) ->
    attr = {}
    attr.remove_avatar = true
    return @save(attr,options)
  
  memberSince: ->
    new Date(@get('member_since'))
  
  ban: (attr) ->
    attr ||= {}
    attr.url = "/v1/users/#{@id}/ban.json"
    return @save({},attr)
  
  unban: (attr) ->
    attr ||= {}
    attr.url = "/v1/users/#{@id}/unban.json"
    return @save({},attr)