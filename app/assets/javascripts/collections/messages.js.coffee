class Cloudsdale.Collections.Messages extends Backbone.Collection

  model: Cloudsdale.Models.Message
  url: -> "/v1/#{@topic.type}s/#{@topic.id}/chat/messages.json"

  initialize: (models,args) ->
    @topic = args.topic
