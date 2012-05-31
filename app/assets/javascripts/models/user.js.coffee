class Cloudsdale.Models.User extends Backbone.Model
  
  url: -> "/v1/users/#{@id}.json"
  type: 'user'
  
  defaults:
    name: ""
    avatar: {}
    clouds: []
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
  
  add_cloud: (cloud,options) ->
    
    options = {} unless options
    
    options.url = "/v1/clouds/#{cloud.id}/users.json"
    options.type = 'POST'
    
    return @save({},options)
  
  leave_cloud: (cloud,options) ->
    
    options = {} unless options
    
    options.url = "/v1/clouds/#{cloud.id}/users/#{@id}.json"
    options.type = 'DELETE'
    
    return @save({},options)
  
  isMemberOf: (cloud) ->
    $.inArray(cloud.id, _.map(@get('clouds'), (c) -> c.id)) >= 0