Cloudsdale.RootRoute = Ember.Route.extend
  templateName: 'root'

  setupController: (controller, model) ->
    controller.set('currentUser', @get('currentUser'))
    controller.set('session',     @get('session'))

  renderTemplate: ->
    this.render into: 'application'
