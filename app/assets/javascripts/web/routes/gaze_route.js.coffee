Cloudsdale.GazeRoute = Ember.Route.extend

  controllerName: 'gaze'

  defaultQuery:  { limit: 10 }
  defaultFilter: => true

  category:   null

  reloadUrl:  null
  prevUrl:    null
  nextUrl:    null
  nextParams: null
  prevParams: null

  actions:
    more: ->
      @handleMeta(@get('controller').get('store').typeMapFor(Cloudsdale.Spotlight).metadata) unless @get('nextParams') == null
      if @get('nextParams')
        @store.find('spotlight', collectionFilter)
        @clearMeta()

  setupController: (controller, spotlights) ->
    controller = @controllerFor('gaze')
    controller.set('category', @get('category'))
    controller.set('spotlights', spotlights)
    @_super(controller, spotlights)

  renderTemplate: () ->
    @render('header.gaze', outlet: 'header')
    @_super()

  clearMeta: ->
    @set('reloadUrl', null)
    @set('prevUrl', null)
    @set('nextUrl', null)
    @set('nextParams', null)
    @set('prevParams', null)

  handleMeta: (meta) ->
    if meta
      @handleMetaCollection(meta)
      @handleMetaRefs(meta.refs) if meta.refs

  handleMetaRefs: (refs) ->
    for ref in refs
      switch ref.rel
        when 'self'
          @set('reloadUrl', ref.href)
        when 'next'
          @set('nextUrl', ref.href)
        when 'prev'
          @set('prevUrl', ref.href)

  handleMetaCollection: (collection) ->
    for key, val of collection
      switch key
        when 'next'
          @set('nextParams', val)
        when 'prev'
          @set('prevParams', val)

  getPromiseFor: (category) ->
    key =  "gaze:filter"
    key += ":#{category}" if category

    if promise = @get(key)
      Ember.Logger.debug("Fetching #{key} from cache")
    else
      Ember.Logger.debug("Building new #{key}")
      if category
        query = @defaultQuery
        query.category = category
        filter = (spotlight) => (spotlight.get('category') == category)
        promise = @store.filter('spotlight', query, filter)
      else
        promise = @store.filter('spotlight', @defaultQuery, @defaultFilter)

      @set(key,promise)

    return promise

Cloudsdale.GazeCategoryRoute = Cloudsdale.GazeRoute.extend

  model: (params) ->
    @clearMeta()
    @set('category', params.category)
    return @getPromiseFor(params.category)

Cloudsdale.GazeIndexRoute = Cloudsdale.GazeRoute.extend

  model: (params) ->
    @clearMeta()
    @set('category', params.category)
    return @getPromiseFor(params.category)

