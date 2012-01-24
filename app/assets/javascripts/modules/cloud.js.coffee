#= require modules/chat
#= require modules/cloud/extras

do ($ = jQuery) ->
  
  class Cloud
    constructor: (@handler,args) ->
      @parent = args.parent
      @cloudId = if args.cloudId then args.cloudId else @handler.data('cloudId')
      @cloudName = if args.roomName then args.roomName else @handler.data('cloudName')
      
      # Setup Container
      @container = if args.frame then args.frame else $(".cloud-container##{@cloudId}")
      @containerToolbar = @container.find(".cloud-toolbar")
      @containerCloseTrigger = @containerToolbar.find("a.closex")
      
      # Setup Handler
      @handlerTrigger = @handler.find("a")
      @handlerNotificationPlate = @handler.find("span.cloud-notification")
      
      # Set up Chat Room if present
      @extrasWrapper = @container.find('.cloud-extras-wrapper')
      if @extrasWrapper.length == 1
        @extras = @extrasWrapper.cloudExtras
          cloud: @
      
      @chatWrapper = @container.find('.cloud-chat-wrapper')
      if @chatWrapper.length == 1
        @chat = @chatWrapper.chat
          topic: @
          topicId: @cloudId
          topicType: 'cloud'
      
      # Default cloud specific variable values
      @notifications = 0
      @active = false
      
      # General setup
      @bind()
      @render()
      @setNotifications()
    
    # Binds elements to do things on interaction
    bind: =>
      @handlerTrigger.bind "click", =>
        $.event.trigger 'toggle.cloud', @
        false
      
      @containerCloseTrigger.bind "click", =>
        $.event.trigger 'toggle.cloud', @
        false
        
      @handler.bind "toggle.cloud", (e,obj) =>
        if (obj == @) and @active
          @hide()
        else if (obj == @) and @active == false
          @show()
        else if @active
          @hide()
      
      $(window).focus =>
        if @active
          @clearNotifications()
    
    # Prepare the frames for interaction.    
    render: =>
      if $.cookie("cloud:active") == @cloudId then @show() else @hide()
      @setNotifications()

    # Takes the container frame to visable mode.
    show: ->
      $.cookie "cloud:active", @cloudId,
        expires: 365
        path: "/"
      
      @active = true
      @container.addClass('active')
      @handler.addClass('active')
      @clearNotifications()
      if @chat
        unless @chat.seeded then @chat.seed()
        @chat.correctContainerScroll(true)
    
    # Takes the chat frame into minimized mode.
    hide: ->
      @active = false
      @container.removeClass('active')
      @handler.removeClass('active')
    
    # Clears Cloud of all notifications and refreshes the notification plate
    clearNotifications: ->
      @parent.subtractGlobalNotification(@notifications)
      @notifications = 0
      $.cookie "cloud:#{@cloudId}:notifications", @notifications, 
        expires: 365
        path: "/"
      @refreshGraphics()
      
    
    # Appends a notification and refreshes the notification plate unless the Cloud is currently active
    addNotification: ->
      unless @active
        @notifications += 1
        @parent.addGlobalNotification(1)
        $.cookie "cloud:#{@cloudId}:notifications", @notifications, 
          expires: 365
          path: "/"
          @refreshGraphics()
      else
        if (document.window_focus == false)
          @notifications += 1
          @parent.addGlobalNotification(1)
          $.cookie "cloud:#{@cloudId}:notifications", @notifications, 
            expires: 365
            path: "/"
            @refreshGraphics()

    # Fetches the notifications stored in client cookies
    # The purpose is to preserve notifications even though page reloads
    setNotifications: ->
      n = $.cookie("cloud:#{@cloudId}:notifications")
      if typeof n is 'string'
        @notifications = parseInt(n)
      else
        $.cookie "cloud:#{@cloudId}:notifications", @notifications, 
          expires: 365
          path: "/"
      @parent.addGlobalNotification(@notifications)
      @refreshGraphics()
    
    # Sets the notification plate to the current notification value if it is above 0
    # Otherwise it will set the value to an empty string and hide the plate.
    refreshGraphics: ->
      if @notifications > 0 then @handlerNotificationPlate.html(@notifications).show() else @handlerNotificationPlate.html("").hide()
    
  $.fn.cloud = ->
    new Cloud(@,arguments[0])