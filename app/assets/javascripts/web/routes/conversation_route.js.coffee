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
      Ember.Logger.debug("Fetching #{key} from cache")
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
        @transitionTo('root')

  model: (params) ->
    return @getConvoPromise(params.handle).then(
      (
        (r) =>
          setTimeout =>
            switch r.get('access')
              when 'requesting' then @transitionTo('conversation.add', r)
              else @transitionTo('conversation.show', r)
          , 0
      )
    )

Cloudsdale.ConversationAddRoute = Cloudsdale.ConversationRoute.extend

  templateName:   'conversation/add'

  actions:
    add: ->
      @currentModel.save().then(
        ( (r) => @handleAddSuccess(r) )
        ( (e) => @handleAddError(e)   )
      )

  model: (params) ->
    return @getConvoPromise(params.handle).then(
      (
        (r) =>
          setTimeout =>
            switch r.get('access')
              when 'requesting' then @transitionTo('conversation.add', r)
              else @transitionTo('conversation.show', r)
          , 0
      )
    )

  handleAddSuccess: (record) ->
    @get('session').get('conversations').pushObject(record)
    @transitionTo('conversation.show', record)

  handleAddError: (errors) ->
    console.log errors