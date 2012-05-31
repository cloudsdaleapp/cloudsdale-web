class Cloudsdale.Views.Explore extends Backbone.View
  
  template: JST['root/explore']
  className: 'view-container'
  
  initialize: (args) ->
    
    args = {} unless args
    
    @searchedClouds = new Cloudsdale.Collections.Clouds()
    
    @popularClouds = new Cloudsdale.Collections.Clouds [],
      url: -> "/v1/clouds/popular.json"
    
    @recentClouds = new Cloudsdale.Collections.Clouds [],
      url: -> "/v1/clouds/recent.json"
    
    @render()
    @bindEvents()
    
    @searchView = new Cloudsdale.Views.ExploreSearch()
    @.$('.explore-search-wrapper').replaceWith(@searchView.el)
    
    @createView = new Cloudsdale.Views.CloudsNew()
    @.$('.explore-create-wrapper').replaceWith(@createView.el)
          
  render: ->
    $(@el).html(@template(view: @)).attr('data-page-id','explore')
    @renderRecent()
    @renderPopular()
    this
  
  show: ->
    $('.view-container').removeClass('active')
    $(@el).addClass('active')
  
  bindEvents: ->
    
    $("body").on "click.tab.data-api", "[data-toggle=\"tab\"], [data-toggle=\"pill\"]", (e) ->
      e.preventDefault()
      $("a[href=#{$(@).attr('href')}]").tab "show"
    
    setTimeout =>
      @.$("a[href=#explore-popular]").tab('show')
    , 10
    
    $(@el).bind 'page:show', (event,pageId) =>
      @show() if pageId == 'explore'
    
  renderRecent: ->
    @recentClouds.fetch
      success: (collection) =>
        collection.each (model) =>
          view = new Cloudsdale.Views.CloudsPreview(model: model)
          @.$('ul#explore-recent').append(view.el)
  
  renderPopular: ->
    @popularClouds.fetch
      success: (collection) =>
        collection.each (model) =>
          view = new Cloudsdale.Views.CloudsPreview(model: model)
          @.$('ul#explore-popular').append(view.el)