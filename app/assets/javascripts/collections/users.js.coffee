class Cloudsdale.Collections.Users extends Backbone.Collection

  model: Cloudsdale.Models.User
  url: -> "/v1/users.json"
  
  # Public: Tries to find the model inside of the collection
  # if it can't be found it tries to initialize it from the server.
  #
  # Examples: 
  # 
  # collection.findOrInitialize('..someid...')
  # # => Cloud
  #
  # Returns an instance of Cloudsdale.Models.User if found, otherwise undefined.
  findOrInitialize: (args,options) ->
    
    args = if (getObjectClass(args) == "String") then [args] else args
    
    args = {} unless args
    options = {} unless options
    
    if getObjectClass(args) == "Array"
      
      users = []
      ids = []
      
      $.each args, (i,id) =>
        user = @get(id)
        unless user
          ids.push(id)
          user = new Cloudsdale.Models.User({id: id})
        
        users.push(user)
      
      if ids.length > 0
        
        if (options.specific_endpoint == true)
          url = if options.url then options.url else @url()
          data = null
        else
          data = { ids: ids }
        
        options.beforeRequest() if options.beforeRequest
          
        @fetch
          add: true
          data: data
          url: url
          success: (resp, status, xhr) =>
            options.success(resp, status, xhr) if options.success
          error: (resp, xhr, _options) =>
            options.error(resp, xhr, _options) if options.error
      else
        options.success(users, 200, {}) if options.success
      
        
      return users
      
    else
    
      user = @get(args.id)
    
      if user
        if options.fetch
          
          options.beforeRequest() if options.beforeRequest
          
          user.fetch
            success: (resp, status, xhr) => options.success(resp, status, xhr) if options.success
            error: (resp, xhr, _options) => options.error(resp, xhr, _options) if options.error
            
        else
          options.success(user) if options.success
        
      else
        user = new Cloudsdale.Models.User(args)
      
        if user.get('is_transient')
          
          options.beforeRequest() if options.beforeRequest
          
          user.fetch
            success: (resp, status, xhr) => options.success(resp, status, xhr) if options.success
            error: (resp, xhr, _options) => options.error(resp, xhr, _options) if options.error

        else
          options.success(user) if options.success
        
        @add(user)
      
    
      return user
      
      