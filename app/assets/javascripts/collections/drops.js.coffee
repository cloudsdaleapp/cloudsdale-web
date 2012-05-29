class Cloudsdale.Collections.Drops extends Backbone.Collection

  model: Cloudsdale.Models.Drop
  url: -> "/v1/drops"
  
  initialize: (models,options) ->
    
    options ||= {}
    
    @url = options.url if options.url
    @subscription = options.subscription if options.subscription
    @topic = options.topic if options.topic
    
    @page = null
    @nextPage = 0
    @prevPage = null
    @totalResults = null
    @timeThreshold  = null
    
    @bindEvents()
  
  fetchMore: (options) ->
    xhr = @fetch
      add: true
      headers:
        'X-Result-Page' : @nextPage if @nextPage
        'X-Result-Time' : @timeThreshold if @timeThreshold
        
      success: (collection,resp) =>
        @page           = xhr.getResponseHeader('X-Result-Page')
        @nextPage       = xhr.getResponseHeader('X-Result-Next')
        @prevPage       = xhr.getResponseHeader('X-Result-Prev')
        @totalResults   = xhr.getResponseHeader('X-Result-Total')
        @timeThreshold  = xhr.getResponseHeader('X-Result-Time')
        options.success()
  
  bindEvents: ->
    if @subscription
      nfc.on @subscription(), (payload) =>
        
        drop = new Cloudsdale.Models.Drop(payload)
        
        existing_drop = @get(drop.id)
        @remove(existing_drop) if existing_drop
        
        @unshift(drop)
  
  lastPage: ->
    @nextPage == null