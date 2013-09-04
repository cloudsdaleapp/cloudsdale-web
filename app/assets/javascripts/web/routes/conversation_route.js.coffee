Cloudsdale.ConversationRoute = Ember.Route.extend

  templateName: 'conversation'

  model: (params) -> Cloudsdale.Conversation.lookup(@store, params.topic)

  setupController: (controller,model) ->
    @_super(controller,model)
    controller.set('model',model)