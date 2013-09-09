Cloudsdale.GazeController = Ember.ArrayController.extend

  itemController: 'spotlight'

  title: 'Gaze'
  category: null
  spotlights: []

  categoriesDropdownText: ( ()->
    if @get('category') then "category: #{@get('category')}" else "categories"
  ).property('category')