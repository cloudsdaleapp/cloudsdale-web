class Cloudsdale.Views.Explore extends Backbone.View

  template: JST['root/explore']
  id: 'explore-container'
  className: 'view-container scrolling-container'

  events:
    'submit form#explore-search' : 'doSearch'
    'click a.drop-close-search' : 'cancelSearch'

  initialize: (args) ->

    args = {} unless args

    @scope = if args.scope then args.scope else 'popular'
    @params = if args.params then args.params else {}

    @focusedSearch = false

    @render()
    @bindEvents()

    @determineView()

    @currentlyLoading = false

    # @searchView = new Cloudsdale.Views.ExploreSearch()
    # @.$('.explore-search-wrapper').replaceWith(@searchView.el)
    #
    # @createView = new Cloudsdale.Views.CloudsNew()
    # @.$('.explore-create-wrapper').replaceWith(@createView.el)

  render: ->
    $(@el).html(@template(view: @))
    this

  determineView: ->
    switch @scope
      when 'popular' then @activatePopular()
      when 'recent' then @activateRecent()
      when 'search' then @activateSearch()
    false

  bindEvents: ->

    $(@el).bind 'page:show', (event,page_id) => @show() if page_id == 'explore'

    $("body").on "click.tab.data-api", "[data-toggle=\"tab\"], [data-toggle=\"pill\"]", (e) ->
      e.preventDefault()
      $("a[href=#{$(@).attr('href')}]").tab "show"

    setTimeout =>
      @.$("a[href=#explore-popular]").tab('show')
    , 10

    @.$("form#explore-search > input[name=q]").bind 'click', (e) =>
      if @focusedSearch
        @.$('form#explore-search > input[name=q]').select()
        @focusedSearch = false
      e.preventDefault()
      false

    @.$("form#explore-search > input[name=q]").bind 'blur', (e) =>
      @focusedSearch = false

    @.$("form#explore-search > input[name=q]").bind 'focus', (e) =>
      @focusedSearch = true

    $(@el).on 'scroll', =>
      if $(@el).scrollTop() > (@el.scrollHeight - $(@el).innerHeight() - 250)
        @fetchClouds() unless @collection.lastPage() or @currentlyLoading

  show: ->
    $('.view-container').removeClass('active')
    $(@el).addClass('active')

  doSearch: (event) ->

    params = {}
    params.q = @.$("form#explore-search > input[name=q]").val() || ""

    event.preventDefault()
    Backbone.history.navigate("/explore/clouds/search?q=#{encodeURIComponent(params.q)}",true)
    false

  clearPreviousSearch: ->
    @.$('form#explore-search').removeClass('with-search-results')
    false

  cancelSearch: ->
    @clearPreviousSearch()
    @.$("form#explore-search > input[name=q]").val('')
    @.$('form#explore-search').removeClass('with-search-results')
    false

  activatePopular: (e) ->
    @unbindCollection()
    @reloadResults()
    @.$('.explore-tab-nav > li[data-tab-id="popular"]').addClass('active')
    @collection = new Cloudsdale.Collections.Clouds [],
      url: -> "/v1/clouds/popular.json"
    @bindCollection()
    @fetchClouds()
    false

  activateRecent: (e) ->
    @unbindCollection()
    @reloadResults()
    @.$('.explore-tab-nav > li[data-tab-id="recent"]').addClass('active')
    @collection = new Cloudsdale.Collections.Clouds [],
      url: -> "/v1/clouds/recent.json"
    @bindCollection()
    @fetchClouds()
    false

  activateSearch: (e) ->
    @unbindCollection()
    @reloadResults()
    @.$('.explore-tab-nav > li[data-tab-id="search"]').addClass('active')
    @collection = new Cloudsdale.Collections.Clouds [],
      url: => "/v1/clouds/search.json?q=#{encodeURIComponent(@params.q)}"
    @bindCollection()
    @fetchClouds()
    false

  bindCollection: ->
    if @collection
      @collection.on 'add', (_model) =>
        @addResult(_model)

  unbindCollection: ->
    if @collection
      @collection.off 'add'

  fetchClouds: ->
    @currentlyLoading = true
    @collection.fetchMore
      success: (_collection) =>
        @currentlyLoading = false
        @.$('ul#explore-results .loading-content').remove()

  addResult: (_model) ->
    view = new Cloudsdale.Views.CloudsCard(model: _model)
    @.$('ul#explore-results').append(view.el)

  reloadResults: ->
    @.$('ul#explore-results').html("")
    @.$('.explore-tab-nav > li[data-tab-id]').removeClass('active')
    @.$('ul#explore-results').append("<div class='loading-content' />")

