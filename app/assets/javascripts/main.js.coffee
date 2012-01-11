# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

do ($ = jQuery) ->
  
  class DropZone
    
    constructor: (@frame,args) ->
      @form = @frame.find('form')
      @input = @form.find('input#url')
      @pendingIdField = @form.find('input#pending_id')
      @list = @frame.find('ul.drop-list')
      
      @pendingDrop = null
      
      @bind()
    
    bind: =>
      @form.bind 'submit', =>
        @generatePendingDrop()
        true
      .bind 'ajax:beforeSend', =>
        @pendingIdField.val('')
        @input.val('')
      .bind 'ajax:complete', (request,response) =>
        newDrop = $(response.responseText)
        id = newDrop.attr("id")
        @list.find("li##{id}").remove()
        @pendingDrop.replaceWith(newDrop)
    
    generatePendingDrop: ->
      pendingId = @secureRandom(17)
      url = @input.val()
      
      @pendingIdField.val(pendingId)
      @pendingDrop = @list.prepend("<li class='pending' id='#{pendingId}'>
        <h6>#{url}</h6>
      </li>").find("li##{pendingId}")
    
    secureRandom: (n) ->
      n = n + 1 or 17
      str = []
      while --n
        r = Math.floor(Math.random() * 256).toString(16).substr(Math.floor(Math.random() * 2), 1) or String.fromCharCode(65 + (Math.floor(Math.random() * 8)))
        str.push r
      str.join ""

  $.fn.dropZone = ->
    new DropZone(@,arguments[0])
  
  class RainDrop
    
    constructor: (@frame,args) ->
      @rateTrigger = @frame.find('.ratings > a')
      @bind()
    
    bind: =>
      @rateTrigger.live 'ajax:beforeSend', ->
        $(@).addClass('loading')
      .live 'ajax:complete', (request,response) ->
        $(@).parent().html(response.responseText)
      
      
  $.fn.rainDrop = ->
    new RainDrop(@,arguments[0])

$(document).bind 'index_main.load', (e,obj) =>
  $('.dropzone').dropZone()
  $('li.drop').rainDrop()