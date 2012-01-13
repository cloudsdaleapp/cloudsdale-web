do ($ = jQuery) ->
  
  class CloudExtras
    constructor: (@frame,args) ->
      
      @cloud = args.cloud
      # Setup elements
      @expandTrigger = @frame.find('a.expand-trigger')
      @faye = if args.faye then args.faye else @cloud.faye
      
      @bind()
    
    bind: =>
      @expandTrigger.bind 'click', =>
        @frame.toggleClass('expanded')
        if @frame.hasClass('expanded') then @expandTrigger.find('span').text("less") else @expandTrigger.find('span').text("more")
      
      
  $.fn.cloudExtras = ->
    new CloudExtras(@,arguments[0])