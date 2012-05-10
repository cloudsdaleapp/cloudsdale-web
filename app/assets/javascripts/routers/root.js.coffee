class Cloudsdale.Routers.Root extends Backbone.Router
  
  routes:
    ''                    : 'index'
    'notfound'            : 'notFound'
    'error'               : 'serverError'
    'unauthorized'        : 'unauhorized'
    'error/:error_id?:params'     : 'custom'
    
  # Initializes the dynamic Interface
  index: ->
    $.event.trigger 'page:show', "root"
  
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