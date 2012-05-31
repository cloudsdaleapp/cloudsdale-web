class Cloudsdale.Collections.Users extends Backbone.Collection

  model: Cloudsdale.Models.User
  url: -> "/v1/users"
  
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
    
    args = {} unless args
    options = {} unless options
    
    user = @get(args.id)
    
    if user
      if options.fetch
        user.fetch(
          success: (_user) =>
            options.success(_user) if options.success
        )
      else
        options.success(user) if options.success
        
    else
      user = new Cloudsdale.Models.Cloud(args)
      
      if user.get('is_transient')
        user.fetch(
          success: (_user) =>
            options.success(_user) if options.success
        )
      else
        options.success(user) if options.success
        
      @add(user)
      
    
    return user
      