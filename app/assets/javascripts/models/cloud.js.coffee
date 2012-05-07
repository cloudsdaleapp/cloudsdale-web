class Cloudsdale.Models.Cloud extends Backbone.Model
  
  url: -> "/v1/clouds/#{@id}.json"
  
  initialize: ->
    @type = 'cloud'