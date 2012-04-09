class Cloudsdale.Collections.Clouds extends Backbone.Collection

  model: Cloudsdale.Models.Cloud
  url: -> "/v1/clouds"
    