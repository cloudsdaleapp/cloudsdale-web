class Cloudsdale.Routers.Clouds extends Backbone.Router
  
  routes:
    'clouds/:id' : 'show'
  
  show: (id) ->
    model = session.get('clouds')._byId[id]
    # if model == undefined
    #   console.log "does not exsist... fetching..."
    # else
    #   console.log 'exists!'
    
    if $(".view-container[data-cloud-id=#{id}]").size() == 0
      $('.main-container').append new Cloudsdale.Views.CloudsShow(model: model).el
      
    $.event.trigger 'clouds:show', model.id
      
