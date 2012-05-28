class Cloudsdale.Views.CloudsShow extends Backbone.View
 
  template: JST['clouds/show']
  
  model: 'cloud'
  tagName: 'div'
  className: 'view-container'
  
  initialize: ->
    
    @render()
    @bindEvents()
  
  render: ->
    $(@el).html(@template(model: @model)).attr('data-page-id',@model.id)
    this
  
  bindEvents: ->
    $(@el).bind 'page:show', (event,page_id) =>
      @show() if page_id == @model.id
    
    @model.on 'change', (model) =>
      @refreshGfx()
  
  refreshGfx: ->
    # ...
  
  show: ->
    $('.view-container').removeClass('active')
    $(@el).addClass('active')
    if @.$('.chat-container').length == 0
      @chat_view = new Cloudsdale.Views.CloudsChat(model: @model)
      @.$('.float-container').html(@chat_view.el)
    else
      @chat_view.correctContainerScroll(true)
    
    if @.$('.drop-wrapper').children().length == 0
      @drop_view = new Cloudsdale.Views.CloudsDrops(model: @model)
      @.$('.drop-wrapper').replaceWith(@drop_view.el)