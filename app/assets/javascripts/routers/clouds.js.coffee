class Cloudsdale.Routers.Clouds extends Backbone.Router
  
  routes:
    'clouds/:id' : 'show'
  
  show: (id) ->
    
    args = {}
    args.id = id
    
    if session.isLoggedIn()
      cloud = session.get('clouds').findOrInitialize args,
        success: (cloud) =>
          if cloud.containsUser(session.get('user'))
            @renderCloudPage(args,cloud)
          else
            session.get('user').add_cloud cloud,
              success: () =>
                @renderCloudPage(args,cloud)
                
    else
      Backbone.history.navigate("/",true)
      
      view = new Cloudsdale.Views.SessionsDialog(state: 'login', callback: @renderCloudPage, callbackArgs: args).el
      if $('.modal-container').length > 0 then $('.modal-container').replaceWith(view) else $('body').append(view)
      
      false
    
  
  renderCloudPage: (args,cloud) ->
      
    $.event.trigger 'clouds:join', cloud

    if $(".view-container[data-page-id=#{args.id}]").size() == 0
      $('.main-container').append new Cloudsdale.Views.CloudsShow(model: cloud).el

    $.event.trigger 'page:show', cloud.id
    