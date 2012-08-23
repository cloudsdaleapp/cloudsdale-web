class Cloudsdale.Views.CloudsChat extends Backbone.View
  
  template: JST['clouds/chat']
  
  tagName: 'div'
  className: 'chat-wrapper'
  
  initialize: ->
    
    @render()
        
    @fetchMessages()
    @bindEvents()

    @lastMessageView = null
    @lastAuthorId = null
    
  render: ->
    $(@el).html(@template(model: @model))
    this
  
  # Binds events on certain elemnts
  bindEvents: ->
    @.$('textarea.chat-message-content').expandingTextarea().keydown (e) =>
      @resizeElements()
      if e.which == 13 and e.shiftKey == false
        _content = JSON.stringify(@.$('textarea.chat-message-content').val())
        _content = _content.replace(/^"/,"").replace(/"$/,"").replace(/\\"/ig,'"').replace(/\\/ig,"\\")
        @createNewMessage
          content: _content
          timestamp: Date().toString()
        , true # True for saving
          
        @resetForm()
        false
    
    $(@el).bind "clouds:#{@model.id}:chat:inspect:user", (event,user) =>
      @toggleUserInspect(user)
      
    nfc.on "#{@model.type}s:#{@model.id}:chat:messages", (payload) =>
      if payload.client_id != session.get('client_id')
        payload.topic = @model
        message = new Cloudsdale.Models.Message(payload)
        
        @appendMessage(message)
  
  # Creates and saves a new message and then appends it to
  # the DOM for the current topic.
  #
  # args - The arguments to be passed to the message model
  # do_save - Boolean determining if the model should be saved or not
  #
  # Returns the message model.
  createNewMessage: (args,do_save) ->
    
    args ||= {}
    args.topic = @model
    args.user = session.get('user')
    args.client_id = session.get('client_id')
        
    message = new Cloudsdale.Models.Message(args)
        
    @appendMessage(message)

    message.save {},
      success: (message) =>
        @lastMessageView.appendDrops(message)
        @lastMessageView.refreshGfx()
        @correctContainerScroll(@isNotReadingHistory())
        
    return message
    
  # Fetches the messages related to the chat and appends them to the chat frame.
  #
  # Returns the collection of messages.
  fetchMessages: ->
    collection = new Cloudsdale.Collections.Messages([],topic: @model)
    collection.fetch
      success: (messages) =>
        messages.each (message) =>
          @appendMessage(message)
        @.$('.loading-content').addClass('load-ok')
        setTimeout ->
          @.$('.loading-content').remove()
        , 500
      error: (messages) => @.$('.loading-content').addClass('load-error')
      
    return collection
    
  # Appends a message to the bottom of the message container.
  # If the last sender message was from the same sender as the new message
  # append the the new message to the last one insted of creating a new one.
  #
  # message - An instance of the message model. 
  #
  # Returns the message view.
  appendMessage: (message) ->
    readyForScroll = @isNotReadingHistory()

    if (message.get('user').id == @lastAuthorId) && (@lastMessageView != null) && (message.selfReference() == false)
      @lastMessageView.appendContent(message)
      @lastMessageView.appendDrops(message)
      @lastMessageView.refreshGfx()
    else
      view = new Cloudsdale.Views.CloudsChatMessage(model: message)
      @.$('.chat-messages').append(view.el)
      # Let's remember what message view was appended last
      # and from which user id it was sent.
      if message.selfReference()
        @lastMessageView = null
      else
        @lastMessageView = view
        @lastMessageView.refreshGfx()
        
      @lastAuthorId = message.get('user').id
    
    @popLastMessage()
    @correctContainerScroll(readyForScroll)
  
  # Pops the last message from the view
  #
  # Returns the pop'd message if a message was pop'd
  popLastMessage: ->
    if @.$('.chat-messages').children('div.chat-message').size() > 50
      return @.$('.chat-messages').find('div.chat-message:first').remove()
  
  # Checks if the user is reading chat history
  #
  # Should return true if scroll frame is not at maximum scroll down otherwise false.
  isNotReadingHistory: ->
    frame = @.$('.chat-messages')
    (frame[0].scrollHeight - frame.scrollTop() == frame.outerHeight())
  
  # Scrolls chat container down to the bottom if readForCorrection is true.
  #
  # ready - Boolean value telling if the chat frame is ready to be scrolled down or not
  #
  # Returns nothing of intrest.
  correctContainerScroll: (ready) ->
    frame = @.$('.chat-messages')
    frame.scrollTop(frame[0].scrollHeight) if ready
  
  # Resizes the elements in the chat box relative to each other
  #
  # Returns false.
  resizeElements: ->
    window.setTimeout ( =>
      resizeHeight = @.$('.chat-footer').outerHeight()
      @.$('.chat-messages').css
        bottom: resizeHeight
      @correctContainerScroll(true)
    ), 110
    false
  
  # Resets the chat form to it's original values
  #
  # Returns false.
  resetForm: ->
    @.$('textarea.chat-message-content').val("").trigger('input')
    false
  
  startProsecution: () ->
    prosecution = new Cloudsdale.Models.Prosecution(offender: session.get('user'))
    view = new Cloudsdale.Views.CloudsProsecutionDialog(model: prosecution)
    @.$('.chat-wrapper').append(view.el)
  
  toggleUserInspect: (user) ->
    view = new Cloudsdale.Views.CloudsChatUserInspect(model: user, topic: @model).el
    if @.$(".chat-inspect > .chat-inspect-content[data-user-id='#{user.id}']").length > 0
      window.setTimeout =>
        @resizeElements()
      , 10
      $(".chat-inspect > .chat-inspect-content[data-user-id='#{user.id}']").remove()
    else
      window.setTimeout =>
        @resizeElements()
      , 310
      @.$('.chat-inspect').append(view)

    false
    