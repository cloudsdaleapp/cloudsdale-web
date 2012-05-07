class Cloudsdale.Collections.Clouds extends Backbone.Collection

  model: Cloudsdale.Models.Cloud
  url: -> "/v1/clouds"
  
  # Public: Tries to find the model inside of the collection
  # if it can't be found it tries to initialize it from the server.
  #
  # Examples: 
  # 
  # collection.findOrInitialize('..someid...')
  # # => Cloud
  #
  # Returns an instance of Cloudsdale.Models.Cloud if found, otherwise undefined.
  findOrInitialize: (id) ->
    cloud = @get(id) || new Cloudsdale.Models.Cloud(id: id)    