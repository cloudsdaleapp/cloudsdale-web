#= require jquery
#= require jquery_ujs
#= require pjax
#= require jquery.cookie
#= require date
#= require bootstrap

#= require rails.validations
#= require rails.validations.custom
#= require rails.validations.formbuilder_front

#= require users
#= require sessions

$ ->
  
  hide_alert_message = (p) ->
    $(p).replaceWith("<div class='alert-message hidden'></div>")
  
  load_javascript = (controller,action) ->
    $.event.trigger "application.load"
    $.event.trigger "#{controller}.load"
    $.event.trigger "#{action}_#{controller}.load"
  
  $(document).bind 'application.load', =>
    $("form[data-validate='true']").validate()
    
    $(".alert-message > .close").bind "click", (e) ->
      hide_alert_message $(@).parent()

    $(".alert-message.primary").hide().fadeIn(500).delay(8000).fadeOut 500, ->
      hide_alert_message @
    
  $(document).bind 'start.pjax', (a,b,c) ->
    $("[data-validate]:input").twipsy('hide')
    $(".container[data-pjax-container]").fadeOut(50)
  $(document).bind 'end.pjax', (a,b,c) ->
    $(".container[data-pjax-container]").fadeIn(500)
    
    controller = b.getResponseHeader('controller')
    action     = b.getResponseHeader('action')
    if controller != null and action != null
      load_javascript(b.getResponseHeader('controller'),b.getResponseHeader('action'))
      $("body").attr('class', "#{b.getResponseHeader('controller')} #{b.getResponseHeader('action')}")
  
  $(document).ready ->
    load_javascript($("body").data('controller'),$("body").data('action'))