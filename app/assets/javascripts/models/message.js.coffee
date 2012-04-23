class Cloudsdale.Models.Message extends Backbone.Model
  
  sync: railsRestSync
  
  url: -> "/v1/#{@topic.type}s/#{@topic.id}/chat/messages"
  
  initialize: (args) ->
    @topic = args.topic
    @user = if args.user then new Cloudsdale.Models.User(args.user) else null
      
  timestamp: ->
    new Date(@get('timestamp'))
  
  toJSON: ->
    {
      content: @get("content")
      client_id: @get("client_id")
    }