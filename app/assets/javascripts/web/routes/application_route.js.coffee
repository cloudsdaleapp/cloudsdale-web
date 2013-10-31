Ember.Route.reopen
  beforeModel: ->
    $('.main-content').addClass('loading-content')
  afterModel: (model) ->
    if model && !model.constructor.toString() == 'Cloudsdale.Session'
      model.then () ->
        $('.main-content').removeClass('loading-content')
    else
      $('.main-content').removeClass('loading-content')

Cloudsdale.ApplicationRoute = Ember.Route.extend

  templateName: 'application'

  model: -> @get('session')

  setupController: (controller, model) ->
    controller.set('currentUser', model.get('user'))
    controller.set('conversations', model.get('conversations'))
    controller.set('model', model)

  renderTemplate: ->
    @render()