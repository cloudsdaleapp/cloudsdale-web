class Cloudsdale.Models.Cloud extends Backbone.Model
  
  url: -> "/v1/clouds/#{@id}.json"
  type: 'cloud'
  
  defaults:
    name: ""
    description: ""
    avatar: {}
    is_transient: true
  
  initialize: ->
    @type = 'cloud'
  
  removeAvatar: (options) ->
    attr = {}
    attr.remove_avatar = true
    return @save(attr,options)