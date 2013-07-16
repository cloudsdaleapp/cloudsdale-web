Cloudsdale.RootRoute = Ember.Route.extend
  templateName: 'root'

  renderTemplate: ->
    this.render into: 'application'
