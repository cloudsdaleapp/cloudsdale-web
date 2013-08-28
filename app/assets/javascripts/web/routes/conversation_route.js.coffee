Cloudsdale.ConversationRoute = Ember.Route.extend

  templateName: 'conversation'

  model: (params) -> Cloudsdale.Conversation.find(params.topic, fetch: false)

  setupController: (controller,model) ->
    @_super(controller,model)
    controller.set('model',model)