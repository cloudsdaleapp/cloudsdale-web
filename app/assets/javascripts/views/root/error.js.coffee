class Cloudsdale.Views.Error extends Backbone.View
  
  template: JST['root/error']
  
  className: 'view-container error-container'
  
  initialize: (args) ->
    @errorType = args.errorType
    
    @title = args.title if args.title
    @subTitle = args.subTitle if args.subTitle
       
    @render()
    @bindEvents()
    @refreshGfx()
  
  render: ->
    $(@el).html(@template(view: @))
    this
  
  bindEvents: ->
    $(@el).bind 'page:show', (event,pageId) =>
      @show() if $.inArray(pageId, ["unauthorized","notfound","servererror","custom"]) >= 0
  
  show: ->
    $('.view-container').removeClass('active')
    $(@el).addClass('active')
  
  refreshGfx: ->
    $(@el).addClass(@errorType)
    
    if @errorType == 'unauthorized'
      @.$('h1').text('Who goes there?')
      @.$('h3').text('You are unauthorized to view this page.')
      
    else if @errorType == 'notfound'
      @.$('h1').text('The world is round, there is no up or down.')
      @.$('h3').text("The page you were looking for does not exist.")
      
    else if @errorType == 'servererror'
      @.$('h1').text("I just don't know what went wrong.")
      @.$('h3').text('Something went wrong when you tried to view this page.')
    
    else
      @.$('h1').text(@title)
      @.$('h3').text(@subTitle)