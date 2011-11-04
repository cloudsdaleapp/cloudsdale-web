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
  $("#flash.showme").hide().delay(200).fadeIn(400).delay(3000).fadeOut(400)
  
  $("form.with_notifications").live('ajax:complete', (a,b) ->
    r = $.parseJSON(b.responseText)
    $("#flash").addClass('showme').hide().fadeIn(400).delay(3000).fadeOut(400)
    $("p#flash_bubble").text("#{r.flash.message}").removeClass('notice').removeClass('error').addClass("#{r.flash.type}")
  )
  
  $(".alert-message > .close").bind "click", (e) ->
    $(this).parent().replaceWith("<div class='alert-message hidden'></div>")
  
  $('.topbar').dropdown()
  $('[rel=twipsy]').twipsy()

  request = (options) ->
    $.ajax $.extend(
      url: options.url
      type: "get"
    , options)
    false
  