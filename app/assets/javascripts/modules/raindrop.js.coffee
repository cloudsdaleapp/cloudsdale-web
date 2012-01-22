class RainDrop
  
  constructor: (@frame,args) ->
    @votesContainer = @frame.find('nav > span.votes')
    @voteTrigger = @votesContainer.find('a')
    @bind()
  
  bind: =>
    @voteTrigger.live 'ajax:beforeSend', ->
      $(@).addClass('loading')
    .live 'ajax:complete', (request,response) ->
      $(@).parent().replaceWith(response.responseText)
    
    
$.fn.rainDrop = ->
  new RainDrop(@,arguments[0])