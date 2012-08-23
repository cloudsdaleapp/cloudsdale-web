class Cloudsdale.Models.Message extends Backbone.Model
  
  sync: railsRestSync
  
  url: -> "/v1/#{@get('topic_type')}s/#{@get('topic_id')}/chat/messages"
          
  timestamp: -> new Date(@get('timestamp'))
  
  toJSON: -> { content: @get("content"), client_id: @get("client_id") }
  
  selfReference: -> if @get('content').match(/^\/me/i) then true else false
  
  drops: -> new Cloudsdale.Collections.Drops(@get('drops'))
  
  user: (args) -> return session.get('users').findOrInitialize(@get('author_id'))[0]
  
  topic: (args) -> return session.get(@get('topic_type') + 's').findOrInitialize(@get('topic_id'))