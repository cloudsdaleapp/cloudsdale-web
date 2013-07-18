Cloudsdale.Sidebar ||= Ember.Namespace.create()
Cloudsdale.Sidebar.ConversationView = Ember.View.extend
  templateName: 'sidebar/conversation'
  classNames: ['sidebar-conversation']
  tagName: 'li'

  didInsertElement: (topic) ->
    console.log @get('controller')
