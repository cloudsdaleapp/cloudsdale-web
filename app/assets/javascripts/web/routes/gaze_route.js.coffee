Cloudsdale.GazeRoute = Ember.Route.extend

  templateName: 'gaze'

  filter: { limit: 1 }

  reloadUrl:  null
  prevUrl:    null
  nextUrl:    null
  nextParams: null
  prevParams: null

  isLoading:  false

  events:
    more: ->
      if @nextParams == null
        @handleMeta(@get('controller').get('store').typeMapFor(Cloudsdale.Spotlight).metadata)
      @loadMore()

  model: (params) ->
    @loadRecords(@filter)
    return Cloudsdale.Spotlight.filter()

  loadMore: ->
    @loadRecords(@nextParams) if @nextParams

  loadRecords: (collectionFilter) ->
    promise = Cloudsdale.Spotlight.find(collectionFilter)
    @clearMeta()

  setupController: (controller,model) ->
    @_super(controller,model)
    controller.set('model',model)

  clearMeta: ->
    @reloadUrl  = null
    @prevUrl    = null
    @nextUrl    = null
    @nextParams = null
    @prevParams = null

  handleMeta: (meta) ->
    if meta.collection
      @handleMetaCollection(meta.collection)
      @handleMetaRefs(meta.collection.refs) if meta.collection.refs

  handleMetaRefs: (refs) ->
    refs.forEach (ref) =>
      switch ref.rel
        when 'self'
          @reloadUrl = ref.href
        when 'next'
          @nextUrl   = ref.href
        when 'prev'
          @prevUrl   = ref.href

  handleMetaCollection: (collection) ->
    for key, val of collection
      switch key
        when 'next'
          @nextParams = val
        when 'prev'
          @prevParams = val
