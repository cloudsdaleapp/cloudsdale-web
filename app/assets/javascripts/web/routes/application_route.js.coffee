Cloudsdale.ApplicationRoute = Ember.Route.extend

  templateName: 'application'

  model: -> @get('session')

  setupController: (controller, model) ->
    controller.set('currentUser', model.get('user'))
    controller.set('conversations', model.get('conversations'))
    controller.set('model', model)

  renderTemplate: ->
    @render()