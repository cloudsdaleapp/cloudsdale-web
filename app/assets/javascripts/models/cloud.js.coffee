class Cloudsdale.Models.Cloud extends Backbone.GSModel
  
  url: -> "/v1/clouds/#{@id}.json"
  type: 'cloud'
  
  setters:
    
    owner: (value) -> new Cloudsdale.Models.User(value)
      
    users: (value) ->
      new Cloudsdale.Collections.Users value,
        url: -> "/v1/clouds/#{@id}/users.json"
            
    moderators: (value) ->
      new Cloudsdale.Collections.Users value,
        url: -> "/v1/clouds/#{@id}/moderators.json"
    
  defaults:
    name: ""
    description: ""
    avatar: {}
    owner: -> new Cloudsdale.Models.User()
    moderators: -> new Cloudsdale.Collections.Users()
    users: -> new Cloudsdale.Collections.Users()
    is_transient: true
  
  initialize: (args) ->
    
    args = {} unless args
      
  removeAvatar: (options) ->
    attr = {}
    attr.remove_avatar = true
    return @save(attr,options)