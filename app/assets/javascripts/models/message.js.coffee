class Cloudsdale.Models.Message extends Backbone.Model
  
  sync: railsRestSync
  
  url: -> "/v1/#{@get('topic').type}s/#{@get('topic').id}/chat/messages"
  
  initialize: (args) ->
    args ||= {}
    
    if args.topic
      topic = session.get('clouds').findOrInitialize(args.topic)
      @set('topic',topic)
    
    if args.author
      user = session.get('users').findOrInitialize(args.author)
      @set('user',user)
          
  timestamp: ->
    new Date(@get('timestamp'))
  
  toJSON: ->
    {
      content: @get("content")
      client_id: @get("client_id")
    }