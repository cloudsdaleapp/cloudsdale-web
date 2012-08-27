class Cloudsdale.Collections.Clouds extends Backbone.Collection

  model: Cloudsdale.Models.Cloud
  url: -> "/v1/clouds"
  comparator: (_model) ->
    return -_model.lastMessageAt().getTime()
  
  initialize: (models,options) ->
    
    options ||= {}
    
    @url = options.url if options.url
    @topic = options.topic if options.topic
    
    @page = null
    @nextPage = 0
    @prevPage = null
    @totalResults = null
    @timeThreshold  = null
      
  # Public: Tries to find the model inside of the collection
  # if it can't be found it tries to initialize it from the server.
  #
  # Examples: 
  # 
  # collection.findOrInitialize('..someid...')
  # # => Cloud
  #
  # Returns an instance of Cloudsdale.Models.Cloud if found, otherwise undefined.
  findOrInitialize: (args,options) ->
    
    args = {} unless args
    options = {} unless options
    
    cloud = @get(args.id)
            
    if cloud
      if options.fetch
        cloud.fetch(
          success: (_cloud) =>
            options.success(_cloud) if options.success
        )
      else
        options.success(cloud) if options.success
        
    else
      cloud = new Cloudsdale.Models.Cloud(args)
            
      if cloud.get('is_transient')
        cloud.fetch(
          success: (_cloud) =>
            options.success(_cloud) if options.success
        )
      else
        options.success(cloud) if options.success
        
      @add(cloud)
      
    
    return cloud
      
  fetchMore: (options) ->
    
    options = {} unless options
    
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
        options.success(collection,resp) if options.success
        
      error: (collection,resp) =>
        options.error(collection,resp) if options.error
  
  lastPage: ->
    @nextPage == null