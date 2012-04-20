class Cloudsdale.Routers.Clouds extends Backbone.Router
  
  routes:
    'clouds/:id' : 'show'
  
  show: (id) ->
    model = session.get('clouds')._byId[id]
    
    if $(".view-container[data-page-id=#{id}]").size() == 0
      $('.main-container').append new Cloudsdale.Views.CloudsShow(model: model).el
      
    $.event.trigger 'page:show', id
      
