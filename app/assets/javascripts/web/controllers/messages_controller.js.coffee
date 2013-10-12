Cloudsdale.MessagesController = Ember.ArrayController.extend
  content: Ember.A([])

  sortProperties: ['timestamp']
  sortAscending: true

  itemController: 'message'
