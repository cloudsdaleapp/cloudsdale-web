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