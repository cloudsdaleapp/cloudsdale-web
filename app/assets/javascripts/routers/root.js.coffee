class Cloudsdale.Routers.Root extends Backbone.Router
  
  routes:
    ''                            : 'index'
    '_=_'                         : 'redirectIndex'
    'explore'                     : 'explore'
    'info'                        : 'info'
    'notfound'                    : 'notFound'
    'error'                       : 'serverError'
    'unauthorized'                : 'unauhorized'
    'error/:error_id?:params'     : 'custom'
    
  # Initializes the dynamic Interface
  index: ->
    $.event.trigger 'page:show', "root"
  
  redirectIndex: ->
    Backbone.history.navigate("/",true)
  
  explore: ->
        
    if $(".view-container[data-page-id=explore]").size() == 0
      $('.main-container').append new Cloudsdale.Views.Explore().el
      
    $.event.trigger 'page:show', "explore"
    
  info: ->
        
    if $(".view-container[data-page-id=info]").size() == 0
      $('.main-container').append new Cloudsdale.Views.Info().el
      
    $.event.trigger 'page:show', "info"
    
  notFound: ->
    @asserErrorContainerAndRender("notfound")
    
  serverError: ->
    @asserErrorContainerAndRender("servererror")
  
  unauhorized: ->
    @asserErrorContainerAndRender("unauthorized")
  
  custom: (error_id,params) ->
    args = deparam(params)
    @asserErrorContainerAndRender("custom",args.title,args.sub_title)
    
  asserErrorContainerAndRender: (id,title,subTitle) ->
    
    view = new Cloudsdale.Views.Error(errorType: id, title: title, subTitle: subTitle)
        
    if $('.main-container .view-container.error-container').length > 0
      $('.main-container .view-container.error-container').replaceWith(view.el)
    else
      $('.main-container').append(view.el)      
      
    $.event.trigger 'page:show', id