class Cloudsdale.Routers.Root extends Backbone.Router

  routes:
    ''                            : 'index'
    '_=_'                         : 'redirectIndex' # For facebook redirect.
    ':pageId'                     : 'page'

  # Initializes the dynamic Interface
  index: ->
    @renderPage 'root',
      success: =>
        $('#page-container .root-get-started').replaceWith(new Cloudsdale.Views.RootSession().el)

  page: (pageId) ->
    @renderPage(pageId)

  redirectIndex: -> Backbone.history.navigate("/",true)

  renderPage: (pageId,args) ->

    args ||= {}

    $("#page-container > .container.paper-container").html('<div class="loading-content" />')
    $.event.trigger 'page:show', "page"

    if window.page_src

      if _.include([404,401,403,500],statusCode)
        $("#page-container > .container.paper-container").html(@statusView(statusCode).el)
        args.error() if args.error
      else
        $("#page-container > .container.paper-container").html(page_src)
        args.success() if args.success

      window.page_src = undefined
      @prependSocial()

    else
      $.ajax
        type: 'GET'
        url: "/#{pageId}?layout=false"
        success: (response) =>
          $("#page-container > .container.paper-container").html(response)
          @prependSocial()
          args.success() if args.success
        error: (response) =>
          $("#page-container > .container.paper-container").html(@statusView(response.status).el)
          args.error() if args.success

  statusView: (status) ->
    switch status
      when 404
        view = new Cloudsdale.Views.Error({errorType: "notfound"})
      when 401
        view = new Cloudsdale.Views.Error(errorType: "unauthorized")
      when 403
        view = new Cloudsdale.Views.Error(errorType: "unauthorized")
      when 500
        view = new Cloudsdale.Views.Error(errorType: "servererror")

  prependSocial: ->
    $("#page-container > .container.paper-container").prepend('<ul class="social-connect"><ul>')

    $('.social-connect').append("<li class='social-connect-facebook'>#{Facebook.likeButton()}</li>")
    twt = $('.social-connect').append("<li class='social-connect-twitter'></li>").find('li.social-connect-twitter')
    twt.twitterButton()
    ftr = $('.social-connect').append("<li class='social-connect-flattr'></li>").find('li.social-connect-flattr')
    ftr.flattrButton()





