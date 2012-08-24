class Cloudsdale.Routers.Clouds extends Backbone.Router
  
  routes:
    'clouds/:id' : 'show'
  
  show: (id) ->
    
    args = {}
    args.id = id
    
    fail_to_load = (_id) =>
      $(".loading-content.loader-cloud[data-entity-id='#{_id}']").addClass('load-error')
      setTimeout ->
        $(".loading-content.loader-cloud[data-entity-id='#{_id}']").remove()
        Backbone.history.navigate("/",true)
      , 500
    
    if session.isLoggedIn()
      
      cloud = session.get('clouds').findOrInitialize args,
        
        beforeRequest: =>
          $('body').append("<div class='loading-content loader-cloud' data-entity-id='#{id}'/>")
        
        success: (cloud) =>
          if cloud.containsUser(session.get('user'))
            @renderCloudPage(args,cloud)
          else
            session.get('user').addCloud cloud,
              success: () => @renderCloudPage(args,cloud)
              error: => fail_to_load(id)
        
        error: => fail_to_load(id)
          
                
    else
      Backbone.history.navigate("/",true)
      
      view = new Cloudsdale.Views.SessionsDialog(state: 'login', callback: @renderCloudPage, callbackArgs: args).el
      if $('.modal-container').length > 0 then $('.modal-container').replaceWith(view) else $('body').append(view)
      
      false
    
  
  renderCloudPage: (args,cloud) ->
    
    $(".loading-content.loader-cloud[data-entity-id='#{args.id}']").addClass('load-ok')
    setTimeout ->
      $(".loading-content.loader-cloud[data-entity-id='#{args.id}']").remove()
    , 500
    
    $.event.trigger 'clouds:join', cloud

    if $(".view-container[data-page-id=#{args.id}]").size() == 0
      $('.main-container').append new Cloudsdale.Views.CloudsShow(model: cloud).el

    $.event.trigger 'page:show', cloud.id
    