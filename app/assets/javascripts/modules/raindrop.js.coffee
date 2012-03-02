class RainDrop
  
  constructor: (@frame,args) ->
    @dropId = @frame.attr('id')
    @expandTrigger = @frame.find('nav a.drop-expand')
    
    @extrasWrapper = @frame.find('.drop-extras')
    
    @expanded = false
    @extrasLoaded = false
    
    @bind()
    
  bind: =>
    $(document).bind 'expand.drop', (event,target,above,below) =>
      if target == @frame[0] and @expanded == false
        @expandTrigger.find('i').removeClass('icon-chevron-down').addClass('icon-chevron-up')
        @frame.addClass('expanded')
        @frame.prev().addClass('above-expanded')
        @frame.next().addClass('below-expanded')
        @expanded = true
        @loadExtras()
      else if @expanded
        @expanded = false
      
    @expandTrigger.bind 'click', =>
      $('li.drop').removeClass('expanded').removeClass('above-expanded').removeClass('below-expanded')
      $('li.drop > nav > a > i.icon-chevron-up').removeClass('icon-chevron-up').addClass('icon-chevron-down')
      $.event.trigger 'expand.drop', @frame      
      false
  
  loadExtras: =>
    if @extrasLoaded == false
      $.ajax
        url: "/drops/#{@dropId}/extras"
        complete: (response) =>
          if response.status == 200 and @extrasLoaded == false
            @extrasWrapper.html(response.responseText)
            @initReflections()
            @initVotes()
            @extrasLoaded = true
          
  initVotes: =>
    
    @votesContainer = @frame.find('.drop-votes')
    @voteTrigger = @votesContainer.find('a.drop-vote')
    
    @voteTrigger.bind 'ajax:beforeSend', ->
      $(@).addClass('loading')
    .bind 'ajax:complete', (request,response) =>
      @votesContainer.html(response.responseText)
      @initVotes()
  
  initReflections: =>
    @reflectionForm = @frame.find('form')
    @reflectionInput = @reflectionForm.find('textarea')
    @reflectionSubmit = @reflectionForm.find('input[type=submit]')
    @reflectionCounter = @reflectionForm.find('span.drop-reflection-counter')
    @reflectionsList = @frame.find('ul.drop-reflections-list')
    
    @reflectionInput.BetterGrow
      initial_height: 16
      do_not_enter: false
    .bind 'keyup', (e) =>
      cur_len = @reflectionInput.val().length
      @reflectionCounter.html(120-cur_len)
      if cur_len > 120 or cur_len <= 0
        @reflectionForm.addClass('invalid')
        @reflectionSubmit.prop('disabled',true)
      else
        @reflectionForm.removeClass('invalid')
        @reflectionSubmit.prop('disabled',false)
      false
    .bind 'focus', =>
      @reflectionForm.addClass('active')
    .keydown (e) =>
      if e.which == 13 and e.shiftKey == false
        @reflectionForm.submit()
        false
    .trigger 'keyup'
      
    @reflectionForm.bind 'click', (e) =>
      e.stopPropagation()
    .bind 'ajax:beforeSend', =>
      @reflectionInput.val('')
    .bind 'ajax:complete', (request,response) =>
      @reflectionsList.append(response.responseText)

      
    $('html').bind 'click', (e) =>
      @reflectionForm.removeClass('active')    
    
$.fn.rainDrop = ->
  new RainDrop(@,arguments[0])