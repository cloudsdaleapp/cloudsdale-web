Cloudsdale.Sidebar ||= Ember.Namespace.create()
Cloudsdale.Sidebar.ConversationView = Ember.View.extend(
  templateName: 'sidebar/conversation'
  classNames: ['sidebar-conversation']
  tagName: 'li'

  didInsertElement: (topic) ->
    console.log "foo"

  classNameBindings: ['conversationTypeClass']

  conversationTypeClass: (->
    console.log this
    "conversation-topic-#{@model.get('topic').get('type')}" if @model
  ).property("conversationTypeClass")

)
