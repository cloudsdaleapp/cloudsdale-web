class Cloudsdale.Views.CloudsChatMessage extends Backbone.View
  
  template: JST['clouds/chat/message']
  
  model: 'message'
  tagName: 'div'
  className: 'chat-message'
  
  initialize: ->
    @render()
  
  render: ->
    $(@el).html(@template(model: @model))
    this
  
  # Appends content to the message
  appendContent: (message) ->
    @.$('.chat-message-content').append("<p>#{message.get('content')}</p>")
    @.$('.chat-message-meta').html(message.timestamp().toString('HH:mm:ss'))