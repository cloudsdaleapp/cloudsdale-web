Cloudsdale.MessagesRoute = Ember.Route.extend

  viewName: null
  controllerName: 'messages'
  templateName: 'messages'

  actions:
    saveMessage: (params) ->
      convo   = @modelFor('conversation')
      key     = "convo:#{convo.get('handle').toLowerCase()}:messages:new"
      message = @store.get(key)

      @buildNewMessage
        controller: @get('controller')
        override: true

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
    @buildNewMessage
      controller: controller
      override: false

  buildNewMessage: (opts) ->
    opts ||= {}
    opts.override ||= false

    convo =  @modelFor('conversation')
    topic = convo.get('topic')
    key   = "convo:#{convo.get('handle').toLowerCase()}:messages:new"

    @store.set(key, undefined) if opts.override

    if @store.get(key)
      Ember.Logger.debug("Using #{key} from cache")
    else
      Ember.Logger.debug("Building #{key}")

      message = @store.createRecord(Cloudsdale.Message)

      @get('currentUser').then (user) =>
        message.set('topic',  @modelFor('conversation').get('topic'))
        message.set('author', user)

      @store.set(key, message)
      opts.controller.set('currentMessage', message)

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