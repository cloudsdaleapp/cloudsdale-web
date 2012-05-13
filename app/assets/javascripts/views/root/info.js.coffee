class Cloudsdale.Views.Info extends Backbone.View
  
  template: JST['root/info']
  
  className: 'view-container'
    
  initialize: (args) ->
    @render()
    @bindEvents()
  
  render: ->
    $(@el).html(@template(view: @)).attr('data-page-id','info')
    this
  
  bindEvents: ->
    $(@el).bind 'page:show', (event,pageId) =>
      @show() if pageId == 'info'
  
  show: ->
    $('.view-container').removeClass('active')
    $(@el).addClass('active')