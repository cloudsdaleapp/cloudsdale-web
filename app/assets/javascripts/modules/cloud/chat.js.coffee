do ($ = jQuery) ->
  
  class ChatContainer
    constructor: (@frame,args) ->
      @messagesWrapper = @frame.find(".cloud-chat-messages")
      @messageform = @frame.find("form")
      @messageInput = @form.find("textarea")
      
    # seed: ->
    #   # Appends last 30 messages from designated chat room into the container.
    #   unless @seeded
    #     $.getJSON "/chat/rooms/#{@room_id}/messages", (data) =>
    #       i = data.length - 1
    #       $.each data, (key, val) =>
    #         @appendMessage(val.timestamp,val.content,val.user_name,val.user_path,val.user_avatar,val.author_id)
    #         @correctContainerScroll(true)
    #         if key == i
    #           window.setTimeout ( =>
    #             @correctContainerScroll(true)
    #           ), 500
    #         
    #       @seeded = true
    #   
    # parseMessageContent: (c) ->
    #   c = c.replace(/<\/?[^>]*>/gi,"")
    #   c = c.replace(/\n/gi,"<br />")
    #   c = c.replace(/<br\/><br\/>/gi,"<br/>")
    #   c = c.replace(/^\s*$/gi,"")
    # 
    #   c = c.replace /([a-z]{1,6}\:\/\/)([a-z0-9\.\,\-\_\:]*)(\/?[a-z0-9\'\"\.\,\-\_\/\?\:\&\=\#\%\+\(\)]*)/gi, (match,protocol,top_dom,path) ->
    #     pjax_data = if top_dom.match(/cloudsdale.org/i) == null then "target='_blank' data-skip-pjax='true'" else ""
    #     "<a class='chat-link' href='#{match}' #{pjax_data}>#{match}</a>"
    #   return c
    # 
    # appendMessage: (timestamp,content,user_name,user_path,user_avatar,uid) =>
    #   # Appends a message to the bottom of the message container.
    #   t = new Date(timestamp)
    #   image = if user_avatar then "src='#{user_avatar}'" else "src='#{@parent.default_avatar_src}'"
    #   if uid == @last_sender_uid
    #     @last_message_frame.append("<p>#{content}</p>")
    #   else
    #     @last_message_frame = @wrapper.append("<div data-timestamp='#{timestamp}'class='chat-message'>
    #         <a href='#{user_path}'><img #{image}/></a>
    #         <header class='chat-message-head'>
    #           <span class='sender'><a href='#{user_path}'>#{user_name}</a></span>
    #           <span class='metadata'>#{t.toString('HH:mm:ss')}</span>
    #         </header>
    #         <article class='chat-message-content'>
    #           <p >#{content}</p>
    #         </article>
    #       </div>").find('div.chat-message:last article')
    #     @last_sender_uid = uid
    # 
    #   @popLastMessages()
    #   @correctContainerScroll(true)
    # 
    # popLastMessages: ->
    #   if @wrapper.children('div.chat-message').size() > @conf_MaxMessages
    #     @wrapper.find('div.chat-message:first').remove()
    # 
    # isReadingHistory: ->
    #   # Should return true if scroll frame is not at maximum scroll down.
    #   (@container[0].scrollHeight - @container.scrollTop() == @container.outerHeight())
    # 
    # correctContainerScroll: (readyForCorrection) ->
    #   # Scrolls chat container down to the bottom if readForCorrection is true.
    #   if readyForCorrection
    #     @wrapper.scrollTop(@wrapper[0].scrollHeight)
    #   
    # resizeElements: ->
    #   window.setTimeout ( =>
    #     resizeHeight = @input.outerHeight() + 9
    #     @wrapper.css
    #       bottom: resizeHeight
    #     @correctContainerScroll(true)
    #   ), 110
    #   
    # validateInput: ->
    #   # Validates the input client side to ease load on chat servers.
    #   if (@input.attr('value').match(/^\s*$/) == null) and (@input.val.length > 0)
    #     true
    #   else
    #     false
    # 
    # resetInput: ->
    #   # Resets the chat input completly.
    #   @input.val('')
    #   
    # refreshGraphics: ->
    #   if @notifications > 0
    #     @notification_plate.html("#{@notifications}")
    #     @notification_plate.show()
    #   else
    #     @notification_plate.html("")
    #     @notification_plate.hide()
    
        # 
    #   @input.BetterGrow
    #     initial_height: 12
    #     do_not_enter: null
    # 
    #   .keydown (e) =>
    #     @resizeElements()
    #     if e.which == 13 and e.shiftKey == false
    #       @form.submit()
    #       false
    # 
    #   @form.bind 'ajax:beforeSend', () =>
    #     @appendMessage(Date.now().toString(),@parseMessageContent(@input.val()),@parent.user_name,@parent.user_path,@parent.user_avatar,@parent.uid)
    #     @resetInput()
    #   .submit () =>
    #     @validateInput()
    # 
    #   # Set up subscription to room's message broadcast channel
    #   @faye.subscribe "/chat/room/#{@room_id}", (data) =>
    #     @addNotification()
    #     if @seeded and @parent.uid != data.uid
    #       @appendMessage(data.timestamp,data.content,data.user_name,data.user_path,data.user_avatar,data.uid)
      
  $.fn.container = ->
    new ChatContainer(@,arguments[0])