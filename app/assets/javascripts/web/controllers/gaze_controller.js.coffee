Cloudsdale.GazeController = Ember.Controller.extend

  title: 'Gaze'

  spotlights: ( () ->
    return @get('model')
  ).property('model')
