Cloudsdale.ConversationController = Ember.Controller.extend(

  title: ( () ->
    @content.get('topic.displayName')
  ).property('content.topic.displayName')

  description: ( () ->
    @content.get('topic.description')
  ).property('content.topic.description')

  image: ( () ->
    @content.get('topic.avatar')
  ).property('content.topic.displayName')

  access: ( () -> @content.get('access') ).property('content.access')

  needsAccess: ( () ->
    [undefined].contains(@get('access'))
  ).property('access')

  hasAccess: ( () ->
    ['granted'].contains(@get('access'))
  ).property('access')

)