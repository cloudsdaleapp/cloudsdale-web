# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
  #$('a[data-remote=true]').bind('ajax:complete', (a,b,c) ->
  #  $('#center_column').html(b.responseText)
  #  $("#dashboard_navigation > ul > li").removeClass("active")
  #  $(this).parent().addClass("active")
  #)
  
  $('.splasher').popover
    placement:'above'
    offset: -40
    html: true
  