class Cloudsdale.Models.Cloud extends Backbone.Model
  
  url: -> "/v1/clouds/#{@id}.json"
  
  defaults:
    is_transiet: true
  
  initialize: ->
    @type = 'cloud'