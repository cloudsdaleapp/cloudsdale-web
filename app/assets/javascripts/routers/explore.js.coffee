class Cloudsdale.Routers.Explore extends Backbone.Router

  routes:
    'explore?:params'    : 'index'
    'explore'            : 'index'

    'explore/clouds?:params'  : 'clouds'
    'explore/clouds'          : 'clouds'

    'explore/clouds/:scope?:params' : 'cloudsScoped'
    'explore/clouds/:scope'         : 'cloudsScoped'


  index: (params) ->
    @clouds(params)

  clouds: (params) ->
    @cloudsScoped('popular',params)

  cloudsScoped: (scope,params) ->
    params = if params then deparam(params) else {}
    @renderEssentials(scope,params)

  renderEssentials: (scope,params) ->
    _view = new Cloudsdale.Views.Explore(scope: scope, params: params).el
    if $('#explore-container').length >= 1 then $('#explore-container').replaceWith(_view) else $('.main-container').append(_view)
    $.event.trigger 'page:show', "explore"
