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

      time = new Date()
      message.set('createdAt', time)
      message.set('updatedAt', time)
      message.save()

    loadMore: (params) ->
      @loadRecordsFor(@modelFor('conversation'))

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

    if message = @store.get(key)
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

      @loadRecordsFor(convo)

      filter = @store.filter 'message', (record) =>
        _topic = record.get('topic')
        return false if record.get('isNew') and not record.get('isSaving')
        switch _topic.get('type')
          when 'user' then return null
          else return (_topic.id == topic.id)

      @store.set(key, filter)

    return filter

  loadRecordsFor: (convo, params) ->
    key    = "convo:#{convo.get('handle').toLowerCase()}:messages"

    unless @store.get(key + ':loading') == true
      @store.set(key + ':loading', true)

      if params = @store.get(key + ':more')
        @store.set(key + ':more', undefined)
        Ember.Logger.debug("Fetching more #{key} from server")

      else if @store.get(key + ':initial') == undefined
        @store.set(key + ':initial', true)
        Ember.Logger.debug("Fetching initial #{key} from server")

        topic  = convo.get('topic')
        params = { topic: { id: topic.id, type: topic.get('type') } }

      if params
        @store.find('message', params).then(
          ( (record) =>
            @store.set(key + ':loading', false)
            more = @store.typeMapFor(Cloudsdale.Message).metadata.more
            @store.typeMapFor(Cloudsdale.Message).metadata.more = undefined
            @store.set(key + ':more', more)
          ),
          ( (record) =>
            @store.set(key + ':loading', false)
            @store.set(key + ':more', undefined)
          )
        )
