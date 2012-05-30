class Cloudsdale.Views.Explore extends Backbone.View
  
  template: JST['root/explore']
  className: 'view-container'
  
  endPoints:
    popular:
      url: "/v1/clouds/popular.json"
      method: 'GET'
      
    recent:
      url: "/v1/clouds/recent.json"
      method: 'GET'
      
    search:
      url: "/v1/clouds/search.json"
      method: 'POST'
  
  initialize: (args) ->
    
    args = {} unless args
    
    @allClouds = new Cloudsdale.Collections.Clouds()
    
    @popularClouds = new Cloudsdale.Collections.Clouds()
    
    @recentClouds = new Cloudsdale.Collections.Clouds()
    
    
    @render()
    @bindEvents()
          
  render: ->
    $(@el).html(@template(view: @)).attr('data-page-id','explore')
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
      
    # 
    # @.$('form#explore-search').bind 'submit', (event) =>
    #   @fetchFromSearch()
    #   event.preventDefault()
  
  # fetchFromSearch: ->
  #   
  #   submitData = {}
  #   submitData.q = @.$('input[type=text]').attr('value')
  #   
  #   @reloadResults('search',submitData)
  #   
  # fetchPopular: ->
  #   @reloadResults('popular')
  #   
  # fetchRecent: ->
  #   @reloadResults('recent')
  # 
  # nextPage: ->
  #   # TODO
  #   
  # previousPage: ->
  #   # TODO
  #     
  # 
  # reloadResults: (s,data) =>
  #   @state = s
  #   data = {} unless data
  #   @collection.fetch
  #     url: @endPoints[@state].url,
  #     data: data,
  #     type: @endPoints[@state].method,
  #     add: false
  # 
  # renderResults: ->
  #   wrapper = @.$('.explore-results')
  #   # wrapper.children.fadeOut(500)
  #   if @collection.length > 0
  #     cloud = @collection.first()
  #     view = new Cloudsdale.Views.CloudsPreview(model: cloud)
  #     @.$('.explore-preview').replaceWith(view.el)
  #     
  #     @collection.each (cloud) ->
  #       view = new Cloudsdale.Views.CloudsResult(model: cloud)
  #       wrapper.append(view.el)
  # 
  # addCloud: ->