class Cloudsdale.Routers.Root extends Backbone.Router
  
  routes:
    '':'index'
  
  # Initializes the dynamic Interface
  index: ->
    # if $(".view-container[data-page-id=root]").size() == 0
    #   # $('.main-container').append new Cloudsdale.Views.CloudsShow(model: model).el
    #   #
      
    $.event.trigger 'page:show', "root"
    
    console.log session.get('user').get('is_registered')    
