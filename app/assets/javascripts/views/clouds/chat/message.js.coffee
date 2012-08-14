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
    $(@el).html(@template(model: @model)).addClass("role-#{@model.get('user').get('role')}")
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
    
    content = message.get('content')
    content = escapeHTML(content).autoLink({ target: "_blank", rel: 'safe' })
    
    content = content + "\\n"

    # Tab fix
    content = content.replace(/\\t/ig,"&nbsp;&nbsp;&nbsp;&nbsp;")
    
    # Greentext
    content = content.replace(/((^&gt;|\\n&gt;)[\w\d\s\!\'\"\.\,\-\_\/\?\:\&\^\<\>\=\#\%\+\*\~\\√\◊\(\)]*\\n)/ig,"<span style='color: green;'>$1</span>")
    
    # Zee text.
    # if @model.get('user').get('role') == 'founder'
    #   content = content.replace(/^\[ZEE\](.*)/ig,"<span style='color: orange; font-weight: bold;'>$1</span>")
    
    content = content.replace(/\\n$/ig,"").replace(/\\n/ig,"<br/>")
    
    @.$('.chat-message-content').append("<p>#{content}</p>")
    @.$('.chat-message-meta').text(message.timestamp().toString('HH:mm:ss'))
    
  
  openUserInspect: (event) ->
    $.event.trigger "clouds:#{@model.get('topic').id}:chat:inspect:user", @model.get('user')
    false