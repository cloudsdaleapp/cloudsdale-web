Cloudsdale.GazeRoute = Ember.Route.extend

  templateName: 'gaze'

  filter: { limit: 10 }

  reloadUrl:  null
  prevUrl:    null
  nextUrl:    null
  nextParams: null
  prevParams: null

  isLoading:  false

  actions:
    more: ->
      console.log @nextParams
      if @nextParams == null
        @handleMeta(@get('controller').get('store').typeMapFor(Cloudsdale.Spotlight).metadata)
      @loadRecords(@nextParams) if @nextParams

  model: (params) ->
    @loadRecords(@filter)
    return @store.filter('spotlight')

  loadRecords: (collectionFilter) ->
    promise = @store.find('spotlight', collectionFilter)
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
    if meta
      @handleMetaCollection(meta)
      @handleMetaRefs(meta.refs) if meta.refs

  handleMetaRefs: (refs) ->
    for ref in refs
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
