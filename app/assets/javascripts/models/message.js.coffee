class Cloudsdale.Models.Message extends Backbone.Model
  
  sync: railsRestSync
  
  url: -> "/v1/#{@get('topic').type}s/#{@get('topic').id}/chat/messages"
  
  initialize: (args) ->
    args ||= {}
    
    topic = session.get('clouds').findOrInitialize(args.topic)
    @set('topic',topic)
    
    user = session.get('users').findOrInitialize(args.user)
    @set('user',user)
    
    # @get('user').on 'change', -> alert("wat")
      
  timestamp: ->
    new Date(@get('timestamp'))
  
  toJSON: ->
    {
      content: @get("content")
      client_id: @get("client_id")
    }