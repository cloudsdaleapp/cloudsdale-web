$ ->
  chat_frame = $("#chat_frame")
  
  faye = new Faye.Client("<%= Cloudsdale.config['url'] %>:9191/faye")
  
  $("form#new_message").live 'ajax:complete', (a,b,c) ->
    $(this).find(":input").not(':button, :submit, :reset, :hidden')
     .val('')
     .removeAttr('checked')
     .removeAttr('selected')
  
  faye.subscribe "/chat", (data) ->
    chat_frame.append("<div class='message'><div class='sender'>#{data.sender}:</div><div class='content'>#{data.message}</div></div>")
    @scroll = chat_frame.prop('scrollHeight') - chat_frame.prop('clientHeight')
    chat_frame.scrollTop(@scroll)
    