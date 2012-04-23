class Cloudsdale.Views.CloudsChat extends Backbone.View
  
  template: JST['clouds/chat']
  
  model: 'cloud'
  tagName: 'div'
  className: 'container-inner chat-container'
  
  events:
    'click a.sidebar-toggle' : 'toggleSidebar'
  
  initialize: ->
    @render()
    @fetchMessages()
    @bindEvents()
    @announcePresence()
    
    @lastMessageView = null
    @lastAuthorId = null
    
  render: ->
    $(@el).html(@template(model: @model))
    this
  
  # Binds events on certain elemnts
  bindEvents: ->
    # @.$('textarea.chat-message-content').BetterGrow
    #   initial_height: 18
    #   do_not_enter: null
    @.$('textarea.chat-message-content').expandingTextarea().keydown (e) =>
      @resizeElements()
      if e.which == 13 and e.shiftKey == false
        @createNewMessage
          content: @.$('textarea.chat-message-content').val()
          timestamp: Date().toString()
        , true # True for saving
          
        @resetForm()
        false
    
    @.$(".chat-online-list").mousewheel (event, delta) ->
      @scrollTop -= (delta * 30)
      event.preventDefault()
    
    nfc.on "#{@model.type}:#{@model.id}:chat", (payload) =>
      if payload.client_id != session.get('client_id')
        payload.topic = @model
        message = new Cloudsdale.Models.Message(payload)
        
        @appendMessage(message)
    
    nfc.on "#{@model.type}:#{@model.id}:presence", (payload) =>
      @refreshPresence(payload)
  
  # Creates and saves a new message and then appends it to
  # the DOM for the current topic. 
  #
  # args - The arguments to be passed to the message model
  # do_save - Boolean determining if the model should be saved or not
  #
  # Returns the message model.
  createNewMessage: (args,do_save) ->
    args.topic = @model
    message = new Cloudsdale.Models.Message(args)
    message.set('client_id',session.get('client_id'))
    message.user = session.get('user')
    message.set('user', session.get('user'))
    
    @appendMessage(message)
    
    message.save() if do_save == true
    
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

    if message.get('author_id') == @lastAuthorId && @lastMessageView != null
      @lastMessageView.appendContent(message)
    else
      view = new Cloudsdale.Views.CloudsChatMessage(model: message)
      @.$('.chat-messages').append(view.el)
      # Let's remember what message view was appended last
      # and from which user id it was sent.
      @lastMessageView = view
      @lastAuthorId = message.get('author_id')
    
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
  
  # Announces your chat presence in the chat room periodicly
  # every 27 seconds with a 3 second delay before restarting the timer
  #
  # Returns false.
  announcePresence: ->
    setTimeout( =>
      nfc.cli.publish "/#{@model.type}/#{@model.id}/presence", session.get('user')
      setTimeout( =>
        @announcePresence()
      , 27000)
    , 3000)
    false
  
  # Refreshes a users presence in the online list
  #
  # payload - The data of the user
  #
  # Returns false.
  refreshPresence: (payload) ->
    if @.$(".chat-online-list > li[data-user-id=#{payload.id}]").length == 0
      user = new Cloudsdale.Models.User(payload)
      user_view = new Cloudsdale.Views.CloudsChatUser(model: user, topic: @model)
      @.$(".chat-online-list").append(user_view.el)
    else
      $.event.trigger "#{@model.type}:#{@model.id}:presence:#{payload.id}", payload
    
    @refreshSidebarGFX()
    
    false
  
  # Refresh the GFX in the sidebar
  #
  # Returns false.
  refreshSidebarGFX: ->
    users_online = @.$(".chat-online-list").children().length
    @.$(".chat-sidebar-header > span.chat-sidebar-online-count > span.n").html("#{users_online}")
    false
  
  # Toggles the sidebar on and off when toggled
  # off it corrects chat container scroll
  #
  # Returns false to mitigate triggering links to append a hash tag.
  toggleSidebar: ->
    $(@el).toggleClass('expanded-sidebar')
    @correctContainerScroll(true) unless $(@el).hasClass('expanded-sidebar')
    false
      