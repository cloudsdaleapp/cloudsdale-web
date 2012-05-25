class Cloudsdale.Models.Cloud extends Backbone.Model
  
  url: -> "/v1/clouds/#{@id}.json"
  
  defaults:
    name: ""
    description: ""
    avatar: {}
    is_transiet: true
  
  initialize: ->
    @type = 'cloud'
  
  removeAvatar: (options) ->
    attr = {}
    attr.remove_avatar = true
    return @save(attr,options)