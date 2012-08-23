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
    $(@el).html(@template(model: @model)).addClass("role-#{@model.get('user').get('role')}").addClass("device-#{@model.get('device')}")
    
    @appendContent(@model)
    @appendDrops(@model)
    
    $(@el).addClass('self-reference') if @model.selfReference()
    
    this
  
  bindEvents: ->
    @model.get('user').on 'change', (event,user) =>
      @refreshGfx()
  
  refreshGfx: ->
    @.$('.chat-message-avatar a img').attr('src',@model.get('user').get('avatar').thumb) if @model.get('user').get('avatar')
    @.$('.chat-message-head a').text(@model.get('user').get('name')) if @model.get('user').get('name')
    if @.$('ul.chat-message-drops').children().length > 0
      $(@el).addClass('chat-message-with-drops')

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
    
    elem = $("<p></p>")
    if message.selfReference()
      elem.html(message.get('content').replace(/^\/me/i,message.get('user').get('name')))
    else
      elem.html(content)
    
    @.$('.chat-message-content').append(elem)
    @.$('.chat-message-meta').text(message.timestamp().toString('HH:mm:ss'))
  
  appendDrops: (message) ->
    message.drops().each (drop) =>
      view = new Cloudsdale.Views.CloudsDropsListItem(model: drop)
      @.$('ul.chat-message-drops').append(view.el)
  
  openUserInspect: (event) ->
    $.event.trigger "clouds:#{@model.get('topic').id}:chat:inspect:user", @model.get('user')
    false