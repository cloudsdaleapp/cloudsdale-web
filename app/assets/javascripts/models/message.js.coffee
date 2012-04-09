class Cloudsdale.Models.Message extends Backbone.Model
  
  sync: railsRestSync
  
  url: -> "/v1/#{@topic.type}s/#{@topic.id}/chat/messages"
  
  initialize: (args) ->
    @topic = args.topic
  
  timestamp: ->
    new Date(@get('timestamp'))