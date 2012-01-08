# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).bind 'index_main.load', (e,obj) =>
  $('.ratings > a').live 'ajax:beforeSend', ->
    $(@).addClass('loading')
  .live 'ajax:complete', (request,response) ->
    $(@).parent().html(response.responseText)