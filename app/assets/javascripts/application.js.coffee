#= require jquery
#= require jquery_ujs
#= require jquery.cookie
#= require jquery.BetterGrow
#= require jquery.titlealert
#= require date
#= require rails.validations
#= require farbtastic
#= require dashboard

$ ->
  $("#flash.showme").hide().delay(200).fadeIn(400).delay(3000).fadeOut(400)
  
  $("form.with_notifications").live('ajax:complete', (a,b,c) ->
    console.log r = $.parseJSON(b.responseText)
    $("#flash").addClass('showme').hide().fadeIn(400).delay(3000).fadeOut(400)
    $("p#flash_bubble").text("#{r.flash.message}").removeClass('notice').removeClass('error').addClass("#{r.flash.type}")
  )

  request = (options) ->
    $.ajax $.extend(
      url: options.url
      type: "get"
    , options)
    false
  