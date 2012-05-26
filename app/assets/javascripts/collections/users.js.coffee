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
    
    options ||= {}
    
    options.fetch = false
    
    user = @get(args.id)
    
    if user
      user.fetch() if options.fetch
    else
      user = new Cloudsdale.Models.User(args)
      user.fetch() if user.get('is_transient')
      @add(user)

    return user
      