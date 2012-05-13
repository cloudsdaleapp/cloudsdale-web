class Cloudsdale.Views.Explore extends Backbone.View
  
  template: JST['root/explore']
  
  className: 'view-container'
    
  initialize: (args) ->
    @render()
    @bindEvents()
  
  render: ->
    $(@el).html(@template(view: @)).attr('data-page-id','explore')
    this
  
  bindEvents: ->
    $(@el).bind 'page:show', (event,pageId) =>
      @show() if pageId == 'explore'
  
  show: ->
    $('.view-container').removeClass('active')
    $(@el).addClass('active')