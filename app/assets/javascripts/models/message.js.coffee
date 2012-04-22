class Cloudsdale.Models.Message extends Backbone.Model
  
  sync: railsRestSync
  
  url: -> "/v1/#{@topic.type}s/#{@topic.id}/chat/messages"
  
  initialize: (args) ->
    @topic = args.topic
    @user = new Cloudsdale.Models.User(args.user)
  
  timestamp: ->
    new Date(@get('timestamp'))