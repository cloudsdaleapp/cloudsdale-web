Cloudsdale.MessagesRoute = Ember.Route.extend

  viewName: null
  controllerName: 'messages'
  templateName: 'messages'

  actions:
    saveMessage: (params) ->
      message = @get('currentMessage')
      @get('controller').set('currentMessage', @buildNewMessage())
      message.save()

  beforeModel: () ->
    switch @modelFor('conversation').get('access')
      when undefined then @transitionTo('conversation.info', @modelFor('conversation'))

  model: (params) ->
    @messagesFilter(@modelFor('conversation'))

  renderTemplate: () ->
    @render('messages', into: 'application', outlet: 'main')

  setupController: (controller, model) ->
    controller.set('content', model)
    controller.set('model',   model)
    unless @get('currentMessage')
      controller.set('currentMessage', @buildNewMessage())

  buildNewMessage: ->
    message = @store.createRecord(Cloudsdale.Message)

    @get('currentUser').then (user) =>
      message.set('topic',  @modelFor('conversation').get('topic'))
      message.set('author', user)

    @set('currentMessage', message)

    return message

  messagesFilter: (convo) ->
    topic = convo.get('topic')
    key   = "convo:#{convo.get('handle').toLowerCase()}:messages:filter"

    if filter = @store.get(key)
      Ember.Logger.debug("Using #{key} from cache")
    else
      Ember.Logger.debug("Fetching #{key} from server")

      params = { topic: { id: topic.id, type: topic.get('type') } }

      @store.find('message', params)

      filter = @store.filter 'message', (record) =>
        topic = record.get('topic')
        return false if record.get('isNew')
        switch topic.get('type')
          when 'user' then return null
          else return (topic.id == params.topic.id)

      @store.set(key, filter)

    return filter