$ ->
  chat_frame = $("#chat_frame")
  
  faye = new Faye.Client("<%= Cloudsdale.config['url'] %>:9191/faye")
  
  broadcast_chat_presence = () ->
    $.get './chat/connect', (data) ->
      console.log "request made"
    
  chat_input_validation = () ->
    input = $("#new_message > #message")
    if (input.attr('value').match(/^\s*$/) == null) and (input.attr('value').length >= 1) == true
      true
    else
      console.log "lololol"
      console.log input.attr('value').match(/^\S*$/)
      console.log (input.attr('value').length >= 1)
      input.attr('value','')
      false
      
  chat_frame_scroll_manipulation = (scroll_is_at_bottom) ->
    if scroll_is_at_bottom
      @scroll = chat_frame.prop('scrollHeight') - chat_frame.prop('clientHeight')
      chat_frame.scrollTop(@scroll)
      
  $(window).load () ->
    $.get './chat/connect', (data) ->
      console.log "connected to chat"
  
  .unload () ->
    $.get './chat/disconnect', (data) ->
      console.log "disconnected from chat"
  
  $("form#new_message").bind 'ajax:beforeSend', ->
    $("#new_message > #message").val('')
    
  .submit () ->
    chat_input_validation()
  
  
  faye.subscribe "/chat", (data) ->
    scroll_is_at_bottom = (chat_frame[0].scrollHeight - chat_frame.scrollTop() == chat_frame.outerHeight())
    chat_frame.append("<div timestamp='#{data.timestamp}'class='message'><div class='sender'>#{data.sender}</div><div class='content'><p><span class='time'>#{data.humanized_timestamp}</span> - #{data.message}</p></div></div>")
    chat_frame_scroll_manipulation(scroll_is_at_bottom)
  
  faye.subscribe "/system", (data) ->
    eval data
    
    