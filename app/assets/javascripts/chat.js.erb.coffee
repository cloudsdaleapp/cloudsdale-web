$ ->
  chat_frame = $("#chat_frame")
  
  faye = new Faye.Client("<%= Cloudsdale.config['url'] %>:9191/faye")
  
  chat_input_validation = () ->
    input = $("#new_message > #message")
    if (input.attr('value').match(/^\s*$/) == null) and (input.attr('value').length >= 1) is true
      true
    else
      input.attr('value','')
      false
      
  chat_frame_scroll_manipulation = (scroll_is_at_bottom) ->
    if scroll_is_at_bottom
      @scroll = chat_frame.prop('scrollHeight') - chat_frame.prop('clientHeight')
      chat_frame.scrollTop(@scroll)
  
  $("form#new_message").ajaxStart () ->
    $("#new_message > #message").val('')
    
  .submit ->
    chat_input_validation()
    
  
  faye.subscribe "/chat", (data) ->
    scroll_is_at_bottom = (chat_frame[0].scrollHeight - chat_frame.scrollTop() == chat_frame.outerHeight())
    chat_frame.append("<div class='message'><div class='sender'>#{data.sender}:</div><div class='content'>#{data.message}</div></div>")
    chat_frame_scroll_manipulation(scroll_is_at_bottom)