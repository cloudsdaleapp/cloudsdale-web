Cloudsdale.RootRoute = Ember.Route.extend

  setupController: (controller, model) ->
    controller.set('currentUser', @get('currentUser'))
    controller.set('session',     @get('session'))

  renderTemplate: ->
    @render('header.root', outlet: 'header')
    @_super()
