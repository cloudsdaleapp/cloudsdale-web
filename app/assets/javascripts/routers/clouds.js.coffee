class Cloudsdale.Routers.Clouds extends Backbone.Router

  routes:
    'clouds/new'  : 'new'
    'clouds/:id'  : 'show'

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
      $('body').append("<div class='loading-content loader-cloud' data-entity-id='#{id}'/>")
      cloud = session.get('clouds').findOrInitialize args,
        success: (cloud) =>
          $(".loading-content.loader-cloud[data-entity-id='#{id}']").attr('data-entity-id',cloud.id)
          if cloud.containsUser(session.get('user'))
            @allowedToShow cloud,
              callback: =>
                @renderCloudPage({ id: cloud.id },cloud)
          else
            session.get('user').addCloud cloud,
              success: () =>
                @allowedToShow cloud,
                  callback: =>
                    @renderCloudPage({ id: cloud.id },cloud)

              error: => fail_to_load(id)

        error: => fail_to_load(id)


    else
      Backbone.history.navigate("/",true)

      view = new Cloudsdale.Views.SessionsDialog(state: 'login', callback: @renderCloudPage, callbackArgs: args).el
      if $('.modal-container').length > 0 then $('.modal-container').replaceWith(view) else $('body').append(view)

      false

  new: (args) ->
    view = new new Cloudsdale.Views.CloudsNew()
    $('#page-container > .container.paper-container').html(view.el)
    $.event.trigger 'page:show', "show"

  renderCloudPage: (args,cloud) ->
    $(".loading-content.loader-cloud[data-entity-id='#{args.id}']").addClass('load-ok')
    setTimeout ->
      $(".loading-content.loader-cloud[data-entity-id='#{args.id}']").remove()
    , 500

    $.event.trigger 'clouds:join', cloud

    if $(".view-container[data-page-id=#{args.id}]").size() == 0
      $('.main-container').append new Cloudsdale.Views.CloudsShow(model: cloud).el

    $.event.trigger 'page:show', cloud.id

  allowedToShow: (cloud,args) ->
    args ||= {}
    args.callback = if args.callback then args.callback else (->)

    if session.get('user').bans.activeOn(cloud).length >= 1

      $.event.trigger "notifications:add", {
        header: "Warning!",
        body: "You are banned from this Cloud.",
        callback: (e) ->
          false
        afterRender: (e) ->
          false
      }

      $(".loading-content.loader-cloud[data-entity-id='#{cloud.id}']").remove()
      Backbone.history.navigate("/",true)

    else
      args.callback()


