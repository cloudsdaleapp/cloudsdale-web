class Cloudsdale.Views.CloudsChatMessage extends Backbone.View

  template: JST['clouds/chat/message']

  model: 'message'
  tagName: 'div'
  className: 'chat-message'

  initialize: ->
    @render()
    @bindEvents()

  render: ->
    $(@el).html(@template(model: @model))
    .addClass("role-#{@model.user().get('role')}")
    .addClass("device-#{@model.get('device')}")
    .addClass("status-#{@model.user().get('status')}")

    if @model.get('author_id') == @model.topic().get('owner_id')
      $(@el).addClass("role-owner")

    if _.include(@model.topic().get('moderator_ids'), @model.get('author_id')) and @model.get('author_id') != @model.topic().get('owner_id')
      $(@el).addClass("role-mod")

    @.$('.chat-message-avatar > a, .chat-message-head > a').attr('data-entity-id',@model.user().id).attr('data-action',"showUser")

    @appendContent(@model)
    @appendDrops(@model)

    $(@el).addClass('self-reference') if @model.selfReference()

    this

  bindEvents: ->
    @model.user().on 'change', (event,user) =>
      @refreshGfx()

  refreshGfx: ->
    $(@el).removeClass('status-away').removeClass('status-busy')
    .removeClass('status-online').removeClass('status-offline')

    $(@el).addClass("status-#{@model.user().get('status')}")

    @.$('.chat-message-avatar a img').attr('src',@model.user().get('avatar').thumb)
    @.$('.chat-message-head a').text(@model.user().get('name'))
    @.$('.chat-message-head span').text("@" + @model.user().get('username'))
    if @.$('ul.chat-message-drops').children().length > 0
      $(@el).addClass('chat-message-with-drops')

  # Appends content to the message
  appendContent: (message) ->

    content = message.get('content')
    content = escapeHTML(content)

    content = content + "\\n"

    # Use actual newlines
    content = content.replace(/\\n/ig, "\n")

    # Hyperlinks
    content = content.autoLink({ target: "_blank", rel: 'safe' })

    # Tab fix
    content = content.replace(/\\t/ig,"&nbsp;&nbsp;&nbsp;&nbsp;")

    # Greentext
    content = content.replace(/(^|\n)&gt;([^\n]*)(?=\n)/ig, (orig, beginning, text) -> "#{beginning} <span style='color: green;'> &gt;#{text} </span> ")

    # Redacted
    content = content.replace(/(\[REDACTED\])/ig," <span style='color: red; font-weight: bold;'>[REDACTED]</span> ")

    # Italic
    content = content.replace(/(?!^\/me)(^|\s)\/\b([^\/\n]+)\b\/\s/ig, (orig, beg, text) -> " <span style='font-style: italic;'> #{text} </span> ")

    # Actions (/me)
    if message.selfReference()
      content = content.replace(/\n$/ig,"").replace(/\n/ig," ")
      content = content.replace(/^\/me/i,message.user().get('name'))
    else
      content = content.replace(/\n$/ig,"").replace(/\n/ig,"<br/>")
    
    # Connor is Comic Sans
    if @model.user().get('username') is 'Connorcpu'
      content = "<span style='font-family: Comic Sans MS, Comic Sans, Verdana !important; font-size: 1.5em'> #{content} </span>"

    # Chapien is papyrus
    if @model.user().get('username') is 'chapien'
      content = "<span style='font-family: papyrus !important; font-size: 1.5em'> #{content} </span>"

    elem = $("<p></p>")
    elem.html(content)

    @.$('.chat-message-content').append(elem)
    @.$('.chat-message-meta').text(message.timestamp().toString('HH:mm:ss'))

  appendDrops: (message) ->
    message.drops().each (drop) =>
      view = new Cloudsdale.Views.CloudsDropsListItem(model: drop)
      @.$('ul.chat-message-drops').append(view.el)
