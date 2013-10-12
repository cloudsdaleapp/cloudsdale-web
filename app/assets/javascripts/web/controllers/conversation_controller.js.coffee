Cloudsdale.ConversationController = Ember.Controller.extend(

  title: ( () ->
    @content.get('topic').get('displayName')
  ).property('content.topic.displayName')

  access: ( () -> @content.get('access') ).property('content.access')

  needsAccess: ( () ->
    ['requesting'].contains(@get('access'))
  ).property('access')

  hasAccess: ( () ->
    ['granted'].contains(@get('access'))
  ).property('access')

)