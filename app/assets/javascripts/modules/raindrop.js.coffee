class RainDrop
  
  constructor: (@frame,args) ->
    @expandTrigger = @frame.find('nav a.drop-expand')
    
    @expanded = false
    
    @bind()
    @initVotes()
  
  bind: =>
    $(document).bind 'expand.drop', (event,target,above,below) =>
      if target == @frame[0] and @expanded == false
        @expandTrigger.find('i').removeClass('icon-chevron-down').addClass('icon-chevron-up')
        @frame.addClass('expanded')
        @frame.prev().addClass('above-expanded')
        @frame.next().addClass('below-expanded')
        @expanded = true
      else if @expanded
        @expanded = false
      
    @expandTrigger.bind 'click', =>
      $('li.drop').removeClass('expanded').removeClass('above-expanded').removeClass('below-expanded')
      $('li.drop > nav > a > i.icon-chevron-up').removeClass('icon-chevron-up').addClass('icon-chevron-down')
      $.event.trigger 'expand.drop', @frame      
      false
  
  initVotes: =>
    @votesContainer = @frame.find('.drop-votes')
    @voteTrigger = @votesContainer.find('a.drop-vote')
    
    @voteTrigger.bind 'ajax:beforeSend', ->
      $(@).addClass('loading')
    .bind 'ajax:complete', (request,response) =>
      @votesContainer.html(response.responseText)
      @initVotes()
    
$.fn.rainDrop = ->
  new RainDrop(@,arguments[0])