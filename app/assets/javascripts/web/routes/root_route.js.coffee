Cloudsdale.RootRoute = Ember.Route.extend
  templateName: 'root'

  model: -> session.get('user')

  renderTemplate: ->
    this.render into: 'application'
