class Cloudsdale.Views.CloudsChatMessage extends Backbone.View
  
  template: JST['clouds/chat/message']
  
  model: 'message'
  tagName: 'div'
  className: 'chat-message'
    
  events:
    'click a.message-user-inspect' : 'openUserInspect'
  
  initialize: ->
    @render()
    @bindEvents()
  
  render: ->
    $(@el).html(@template(model: @model))
    @appendContent(@model)
    this
  
  bindEvents: ->
    @model.get('user').on 'change', (event,user) =>
      @refreshGfx()
  
  refreshGfx: ->
    @.$('.chat-message-avatar a img').attr('src',@model.get('user').get('avatar').thumb)
    @.$('.chat-message-head a').text(@model.get('user').get('name'))
  
  # Appends content to the message
  appendContent: (message) ->
    
    content = escapeHTML(message.get('content')).autoLink({ target: "_blank" })
    content = content.replace(/\\n/ig,"<br />")
    
    @.$('.chat-message-content').append("<p>#{content}</p>")
    @.$('.chat-message-meta').text(message.timestamp().toString('HH:mm:ss'))
    
  
  openUserInspect: (event) ->
    $.event.trigger "clouds:#{@model.get('topic').id}:chat:inspect:user", @model.get('user')
    false