Cloudsdale.HeaderView = Ember.View.extend
  classNames: ['main-header']

Cloudsdale.Gaze ||= Ember.Namespace.create()
Cloudsdale.Gaze.HeaderView = Cloudsdale.HeaderView.extend
  templateName: 'gaze/header'

Cloudsdale.Conversations ||= Ember.Namespace.create()
Cloudsdale.Conversations.HeaderView = Cloudsdale.HeaderView.extend
  templateName: 'conversations/header'