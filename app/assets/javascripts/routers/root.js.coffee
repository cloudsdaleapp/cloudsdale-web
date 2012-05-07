class Cloudsdale.Routers.Root extends Backbone.Router
  
  routes:
    ''            : 'index'
    'notfound'    : 'notFound'
    'error'       : 'serverError'
    'unauthorized': 'serverError'
    
  # Initializes the dynamic Interface
  index: ->
    $.event.trigger 'page:show', "root"
  
  notFound: ->
    @asserErrorContainerAndRender("notFound")
    
  serverError: ->
    @asserErrorContainerAndRender("serverError")
  
  unauhorized: ->
    @asserErrorContainerAndRender("unauhorized")
  
  
  asserErrorContainerAndRender: (id) ->
    
    view = new Cloudsdale.Views.Error(errorType: id)
        
    if $('.main-container .view-container.error-container').length > 0
      $('.main-container .view-container.error-container').replaceWith(view.el)
    else
      $('.main-container').append(view.el)      
      
    $.event.trigger 'page:show', id