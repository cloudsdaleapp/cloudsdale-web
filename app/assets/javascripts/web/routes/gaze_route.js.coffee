Cloudsdale.GazeRoute = Ember.Route.extend

  templateName: 'gaze'

  model: (params) ->
    null

  setupController: (controller,model) ->
    @_super(controller,model)
    controller.set('model',model)