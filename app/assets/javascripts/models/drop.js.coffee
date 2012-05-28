class Cloudsdale.Models.Drop extends Backbone.Model
  
  url: -> "/v1/drops/#{@id}.json"
  
  defaults:
    url: "http://www.cloudsdale.org"
    title: "Cloudsdale"
    avatar: ""
    is_transient: true
  
  visit: ->
    @save {},
      url: "/v1/drops/#{@id}/visit.json"