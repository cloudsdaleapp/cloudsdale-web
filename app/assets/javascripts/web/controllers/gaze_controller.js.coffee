Cloudsdale.GazeController = Ember.ArrayController.extend

  title: 'Gaze'
  category: null
  spotlights: []

  categoriesDropdownText: ( ()->
    text = "category"
    text += if @get('category') then ": #{@get('category')}" else ": all"
    return text
  ).property('category')