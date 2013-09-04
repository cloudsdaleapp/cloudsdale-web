Cloudsdale.GazeController = Ember.ArrayController.extend

  title: 'Gaze'
  category: null
  spotlights: []

  categoriesDropdownText: ( ()->
    if @get('category') then "category: #{@get('category')}" else "categories"
  ).property('category')