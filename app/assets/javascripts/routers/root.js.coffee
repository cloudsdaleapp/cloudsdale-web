class Cloudsdale.Routers.Root extends Backbone.Router
  
  routes:
    '':'index'
  
  # Initializes the dynamic Interface
  index: ->
    if $(".view-container[data-page-id=root]").size() == 0
      console.log "lol"
      # $('.main-container').append new Cloudsdale.Views.CloudsShow(model: model).el
      #
      
    $.event.trigger 'page:show', "root"
    
