class Cloudsdale.Routers.Clouds extends Backbone.Router
  
  routes:
    'clouds/:id' : 'show'
  
  show: (id) ->
    
    args = {}
    args.id = id
    
    if session.isLoggedIn()
      @renderCloudPage(args)
    else
      Backbone.history.navigate("/",true)
      
      view = new Cloudsdale.Views.SessionsDialog(state: 'login', callback: @renderCloudPage, callbackArgs: args).el
      if $('.modal-container').length > 0 then $('.modal-container').replaceWith(view) else $('body').append(view)
      
      false
    
  
  renderCloudPage: (args) ->
    cloud = session.get('clouds').findOrInitialize args,
      success: (_cloud) =>
                
        $.event.trigger 'clouds:join', _cloud
    
        if $(".view-container[data-page-id=#{args.id}]").size() == 0
          $('.main-container').append new Cloudsdale.Views.CloudsShow(model: _cloud).el
    
        $.event.trigger 'page:show', _cloud.id