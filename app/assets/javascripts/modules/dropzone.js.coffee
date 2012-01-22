#= require modules/raindrop

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
        @validateInput()
      .bind 'ajax:beforeSend', =>
        @generatePendingDrop()
        @pendingIdField.val('')
        @input.val('')
      .bind 'ajax:complete', (request,response) =>
        newDrop = $(response.responseText)
        id = newDrop.attr("id")
        @list.find("li##{id}").remove()
        @pendingDrop.replaceWith(newDrop)
        newDrop.rainDrop()
      
      @input.bind 'keyup', =>
        @transformInputValue()
        @validateInput()
        if @input.val().length <= 0
          @form.removeClass('error')
    
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
    
    transformInputValue: ->
      c = @input.val()
      c = c.replace(/<\/?[^>]*>/gi,"")
      c = c.replace(/^\s*$/gi,"")
      c = c.replace(/^www$/gi,"http://www")
      @input.val(c)
    
    validateInput: ->
      # Validates the input client side to ease load on chat servers.
      if (@input.attr('value').match(/^\s*$/) == null) and (@input.val().length > 0) and @validateUrl(@input.val())
        @form.removeClass('error')
        true
      else
        @form.addClass('error')
        false
    
    validateUrl: (url) ->
      /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/i.test(url)
      
  $.fn.dropZone = ->
    new DropZone(@,arguments[0])