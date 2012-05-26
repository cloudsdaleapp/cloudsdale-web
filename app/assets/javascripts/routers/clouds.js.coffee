class Cloudsdale.Routers.Clouds extends Backbone.Router
  
  routes:
    'clouds/:id' : 'show'
  
  show: (id) ->
    
    args = {}
    args.id = id
    
    cloud = session.get('clouds').findOrInitialize(args)
        
    if $(".view-container[data-page-id=#{id}]").size() == 0
      $('.main-container').append new Cloudsdale.Views.CloudsShow(model: cloud).el
      
    $.event.trigger 'page:show', id