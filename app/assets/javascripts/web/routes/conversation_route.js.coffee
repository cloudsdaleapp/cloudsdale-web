Cloudsdale.ConversationRoute = Ember.Route.extend

  templateName: 'conversation'

  # actions:
  #   error: (result, transition) -> @transitionTo('root')

  model: (params) ->
    @store.find('conversation', params.handle).then (convo) =>
      switch convo.get('access')
        when 'requesting' then @transitionTo('conversation.add', convo)
        else convo

  setupController: (controller, model) ->
    @_super(controller,model)
    controller.set('model',model)

Cloudsdale.ConversationAddRoute = Ember.Route.extend

  controllerName: 'conversation'

  model: (params) ->
    @store.find('conversation', params.handle).then (convo) =>
      switch convo.get('access')
        when 'requesting' then return convo
        else @transitionTo('conversation', convo)

  setupController: (controller, model) ->
    @_super(controller,model)
    controller.set('model', model)