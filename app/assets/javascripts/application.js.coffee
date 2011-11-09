#= require jquery
#= require jquery_ujs
#= require jquery.cookie
#= require jquery.BetterGrow
#= require jquery.titlealert
#= require jquery.tokeninput
#= require bootstrap
#= require date
#= require rails.validations
#= require rails.validations.custom
#= require rails.validations.formbuilder
#= require farbtastic
#= require faye
#= require bottombar
#= require showdown


$ ->  
  $(".alert-message > .close").bind "click", (e) ->
    hide_alert_message $(@).parent()
    
  $(".alert-message.primary").hide().fadeIn(500).delay(8000).fadeOut 500, ->
    hide_alert_message @
  
  $('.topbar').dropdown()
  $('[rel=twipsy]').twipsy()

  hide_alert_message = (p) ->
    $(p).replaceWith("<div class='alert-message hidden'></div>")
    
  request = (options) ->
    $.ajax $.extend(
      url: options.url
      type: "get"
    , options)
    false
  