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
    @collection = if args.collection then args.collection else new Cloudsdale.Collections.Clouds()
    
    @state = if args.state then args.state else 'popular'
    
    @render()
    @bindEvents()
    @renderResults()
    
    @collection.add(session.get('clouds').pop)
      
  render: ->
    $(@el).html(@template(view: @)).attr('data-page-id','explore')
    this
  
  bindEvents: ->
    $(@el).bind 'page:show', (event,pageId) =>
      @show() if pageId == 'explore'
    
    @.$('form#explore-search').bind 'submit', (event) =>
      @fetchFromSearch()
      event.preventDefault()
    
    @collection.on 'reset', (model) =>
      @renderResults()
  
  fetchFromSearch: ->
    
    submitData = {}
    submitData.q = @.$('input[type=text]').attr('value')
    
    @reloadResults('search',submitData)
    
  fetchPopular: ->
    @reloadResults('popular')
    
  fetchRecent: ->
    @reloadResults('recent')
  
  nextPage: ->
    # TODO
    
  previousPage: ->
    # TODO
      
  show: ->
    $('.view-container').removeClass('active')
    $(@el).addClass('active')
  
  reloadResults: (s,data) =>
    @state = s
    data = {} unless data
    @collection.fetch
      url: @endPoints[@state].url,
      data: data,
      type: @endPoints[@state].method,
      add: false
  
  renderResults: ->
    wrapper = @.$('.explore-results')
    # wrapper.children.fadeOut(500)
    if @collection.length > 0
      cloud = @collection.first()
      view = new Cloudsdale.Views.CloudsPreview(model: cloud)
      @.$('.explore-preview').replaceWith(view.el)
      
      @collection.each (cloud) ->
        view = new Cloudsdale.Views.CloudsResult(model: cloud)
        wrapper.append(view.el)
  
  addCloud: ->