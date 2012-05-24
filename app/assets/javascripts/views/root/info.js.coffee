class Cloudsdale.Views.Info extends Backbone.View
  
  template: JST['root/info']
  
  className: 'view-container info'
    
  initialize: (args) ->
    @render()
    @bindEvents()
  
  render: ->
    $(@el).html(@template(view: @)).attr('data-page-id','info')
    this
  
  bindEvents: ->
    $("body").on "click.tab.data-api", "[data-toggle=\"tab\"], [data-toggle=\"pill\"]", (e) ->
      e.preventDefault()
      $("a[href=#{$(@).attr('href')}]").tab "show"
    
    setTimeout =>
      @.$("a[href=#about]").tab('show')
    , 0
    
    $(@el).bind 'page:show', (event,pageId) =>
      @show() if pageId == 'info'
    
    setTimeout =>
      @.$('ul#info-contributors-list').simplyScroll
        speed: 4
    , 10
    
  show: ->
    $('.view-container').removeClass('active')
    $(@el).addClass('active')