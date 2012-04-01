do ($ = jQuery) ->
  class Searchable
    constructor: (@form,args) ->
      @input = @form.find('input[type=text]')
      @bind()
      
      @pendingRequest = false
      @pendingTimeout = 1000
      
    bind: () ->
      $(@form).bind 'submit', (event) ->
        event.preventDefault()
        $.pjax
          container: '[data-pjax-container]'
          url: "#{@.action}?#{$(@).serialize()}"
          
      $(document).bind 'end.pjax', (a,b,c) =>
        if b.getResponseHeader('search') == 'true'
          @input.val('')
          
      
  $.fn.searchable = ->
    new Searchable(@,arguments[0])