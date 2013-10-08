Cloudsdale.Sidebar ||= Ember.Namespace.create()
Cloudsdale.Sidebar.ConversationView = Ember.View.extend(
  templateName: 'sidebar/conversation'
  classNames: ['sidebar-item']
  tagName: 'li'

  classNameBindings: ['conversationTypeClass']

  conversationTypeClass: (()->
    "conversation-topic-#{@modelBinding.get('topic').get('type')}"
  ).property("conversationTypeClass")

  image: ( ()->
    @modelBinding.get('topic').get('avatar') + "&s=32"
  ).property("topic.avatar")

)
