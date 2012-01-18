#= require jquery.BetterGrow

do ($ = jQuery) ->
  
  class Chat
    constructor: (@frame,args) ->
      # Setup elements
      @messagesWrapper = @frame.find(".chat-messages")
      @form = @frame.find("form.chat-form")
      @input = @form.find(".chat-input > textarea")
      
      @topic = args.topic
      @topicId = args.topicId
      @topicType = args.topicType
      
      @userData = document.userData
      @faye = if args.faye then args.faye else @topic.faye
      
      # Add client field
      @form.append("<input name='client_id' type='hidden' value='#{@userData.client_id}'/>")
      
      # Default Chat specific variable values
      @seeded = false
      @lastSenderUid = null
      @lastMessageFrame = null
      
      @bind()
    
    bind: =>
      @input.BetterGrow
        initial_height: 12
        do_not_enter: null
  
      .keydown (e) =>
        @resizeElements()
        if e.which == 13 and e.shiftKey == false
          @form.submit()
          false
  
      @form.bind 'ajax:beforeSend', (a,b) =>
        @appendMessage(Date.now().toString(),@parseMessageContent(@input.val()),@userData.name,@userData.path,@userData.avatar,@userData.id)
        @resetInput()
      .submit () =>
        @validateInput()
  
      # Set up subscription to room's message broadcast channel
      @faye.subscribe "/#{@topicType}/#{@topicId}/chat", (data) =>
        if @userData.client_id != data.client_id
          @topic.addNotification()
          if @seeded
            @appendMessage(data.timestamp,data.content,data.user_name,data.user_path,data.user_avatar,data.uid)
      
      @messagesWrapper.bind "mousewheel", (e, d) =>
        w = @messagesWrapper
        e.preventDefault() if (w.scrollTop() is (w[0].scrollHeight - w.height()) and d < 0) or (w.scrollTop() is 0 and d > 0)
          
      
    seed: ->
      # Appends last [X] messages from designated chat topic into the container.
      unless @seeded
        $.getJSON "/#{@topicType}s/#{@topicId}/messages", (data) =>
          i = data.length - 1
          $.each data, (key, val) =>
            @appendMessage(val.timestamp,val.content,val.user_name,val.user_path,val.user_avatar,val.author_id)
            @correctContainerScroll(true)
            if key == i
              window.setTimeout ( =>
                @correctContainerScroll(true)
              ), 500
            
          @seeded = true
          
    appendMessage: (timestamp,content,user_name,user_path,user_avatar,uid) ->
      # Appends a message to the bottom of the message container.
      t = new Date(timestamp)
      image = if user_avatar then "src='#{user_avatar}'"
      readyForScroll = @isNotReadingHistory()
      if uid == @lastSenderUid
        @lastMessageFrame.append("<p>#{content}</p>")
      else
        @lastMessageFrame = @messagesWrapper.append("<div data-timestamp='#{timestamp}'class='chat-message'>
            <a href='#{user_path}'><img #{image}/></a>
            <header class='chat-message-head'>
              <span class='sender'><a href='#{user_path}'>#{user_name}</a></span>
              <span class='metadata'>#{t.toString('HH:mm:ss')}</span>
            </header>
            <article class='chat-message-content'>
              <p >#{content}</p>
            </article>
          </div>").find('div.chat-message:last article')
        @lastSenderUid = uid
          
      @popLastMessages()
      @correctContainerScroll(readyForScroll)
    
    popLastMessages: ->
      if @messagesWrapper.children('div.chat-message').size() > 30
        @messagesWrapper.find('div.chat-message:first').remove()
    
    isNotReadingHistory: ->
      # Should return true if scroll frame is not at maximum scroll down.
      (@messagesWrapper[0].scrollHeight - @messagesWrapper.scrollTop() == @messagesWrapper.outerHeight())
    
    
    correctContainerScroll: (readyForCorrection) ->
      # Scrolls chat container down to the bottom if readForCorrection is true.
      if readyForCorrection
        @messagesWrapper.scrollTop(@messagesWrapper[0].scrollHeight)
    
    resizeElements: ->
      window.setTimeout ( =>
        resizeHeight = @input.outerHeight() + 9
        @messagesWrapper.css
          bottom: resizeHeight
        @correctContainerScroll(true)
      ), 110
    
    
    parseMessageContent: (c) ->
      c = c.replace(/<\/?[^>]*>/gi,"")
      c = c.replace(/\n/gi,"<br />")
      c = c.replace(/<br\/><br\/>/gi,"<br/>")
      c = c.replace(/^\s*$/gi,"")
    
      c = c.replace /([a-z]{1,6}\:\/\/)([a-z0-9\.\,\-\_\:]*)(\/?[a-z0-9\'\"\.\,\-\_\/\?\:\&\=\#\%\+\(\)]*)/gi, (match,protocol,top_dom,path) ->
        pjax_data = if top_dom.match(/cloudsdale.org/i) == null then "target='_blank' data-skip-pjax='true'" else ""
        "<a class='chat-link' href='#{match}' #{pjax_data}>#{match}</a>"
      return c
    
    validateInput: ->
      # Validates the input client side to ease load on chat servers.
      (@input.attr('value').match(/^\s*$/) == null) and (@input.val.length > 0)
    
    resetInput: ->
      # Resets the chat input completly.
      @input.val('')
      
  $.fn.chat = ->
    new Chat(@,arguments[0])