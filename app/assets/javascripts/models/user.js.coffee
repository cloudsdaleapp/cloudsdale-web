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
  
  addCloud: (cloud,options) ->
    
    options = {} unless options
    
    options.url = "/v1/clouds/#{cloud.id}/users/#{@id}.json"
    options.type = 'PUT'
    
    return @save({},options)
  
  leaveCloud: (cloud,options) ->
    
    options = {} unless options
    
    options.url = "/v1/clouds/#{cloud.id}/users/#{@id}.json"
    options.type = 'DELETE'
    
    return @save({},options)
  
  toJSON: ->
    obj = 
      id: @id
      name: @get('name')
      email: @get('email')
      invisible: @get('invisible')
      time_zone: @get('time_zone')
      
    if @get('password')
      obj.password = @get('password') 
    if @get('avatar_url')
      obj.avatar_url = @get('avatar_url')
    if @get('remove_avatar')
      obj.remove_avatar = @get('remove_avatar')
    if @get('skype_name')
      obj.remove_avatar = @get('skype_name')
      
    return obj
  
  toBroadcastJSON: ->
    obj = @toJSON()
    _.pick obj, "id"
  
  toSelectable: ->
    return { id: @id, text: @get('name'), avatar: @get('avatar').mini }