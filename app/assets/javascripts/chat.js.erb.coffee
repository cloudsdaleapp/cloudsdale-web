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
  
  $("form#new_message").ajaxStart () ->
    $("#new_message > #message").val('')
    
  .submit ->
    chat_input_validation()
    
  
  faye.subscribe "/chat", (data) ->
    chat_frame.append("<div class='message'><div class='sender'>#{data.sender}:</div><div class='content'>#{data.message}</div></div>")
    @scroll = chat_frame.prop('scrollHeight') - chat_frame.prop('clientHeight')
    chat_frame.scrollTop(@scroll)