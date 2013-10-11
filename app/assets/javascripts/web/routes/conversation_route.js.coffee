Cloudsdale.ConversationRoute = Ember.Route.extend

  controllerName: 'conversation'

  getHandlePromise: (id) -> @store.find('handle', id)
  getTopicPromise:  (id) ->
    @getHandlePromise(id).then (record) =>
      ident = record.get('identifiable')
      (@store.fetchRecord(ident) || Ember.RSVP.resolve(ident))

  getConvoPromise: (id) ->
    key = "convo:#{id.toLowerCase()}" if id

    if promise = @store.get(key)
      Ember.Logger.debug("Using #{key} from cache")
    else
      Ember.Logger.debug("Building new #{key}")
      promise = @getTopicPromise(id).then (topic) =>
        convo = null
        @store.all('conversation').some (record) =>
          convo = if (record.get('topic').id == topic.id) then record else null
        convo = @store.createRecord('conversation') if convo == null

        @get('currentUser').then (user) =>
          convo.set('user', user) unless convo.get('user')

        convo.set('topic',  topic) unless convo.get('topic')
        convo.set('handle', id)    unless convo.get('handle')

        (@store.fetchRecord(convo) || Ember.RSVP.resolve(convo))

      @store.set(key, promise)

    return promise

Cloudsdale.ConversationShowRoute = Cloudsdale.ConversationRoute.extend

  templateName:   'conversation'

  actions:
    remove: ->
      @store.deleteRecord(@currentModel)
      @currentModel.save().then (record) =>
        @store.set("convo:#{record.get('handle').toLowerCase()}", undefined)
        @get('session').get('conversations').removeObject(record)
        @replaceWith('root')

  model: (params) ->
    return @getConvoPromise(params.handle).then (r) =>
      switch r.get('access')
        when 'requesting' then @replaceWith('conversation.add', r)
        else @replaceWith('conversation.show', r)

  setupController: (controller, model) ->
    topic = model.get('topic')

    controller.set('model',    model)
    controller.set('topic',    topic)
    controller.set('messages', @messages(topic))

    @_super(controller, model)

  messages: (topic) ->
    obj =
      topic_id:   topic.id
      topic_type: topic.get('type')

    key = "convo:#{obj.topic_type}:#{obj.topic_id}:messages:filter"

    if filter = @store.get(key)
      Ember.Logger.debug("Using #{key} from cache")
    else
      Ember.Logger.debug("Fetching #{key} from server")
      filter = @store.find('message', obj )
      @store.set(key, filter)
    return filter

Cloudsdale.ConversationAddRoute = Cloudsdale.ConversationRoute.extend

  templateName:   'conversation/add'

  actions:
    add: ->
      @currentModel.save().then(
        ( (r) => @handleAddSuccess(r) )
        ( (e) => @handleAddError(e)   )
      )

  model: (params) ->
    return @getConvoPromise(params.handle).then (r) =>
      switch r.get('access')
        when 'requesting' then @replaceWith('conversation.add', r)
        else @replaceWith('conversation.show', r)

  handleAddSuccess: (record) ->
    @get('session').get('conversations').pushObject(record)
    @transitionTo('conversation.show', record)

  handleAddError: (errors) ->
    console.log errors

