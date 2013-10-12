Cloudsdale.ConversationRoute = Ember.Route.extend

  controllerName: 'conversation'
  templateName:   'conversation'
  viewName:       'conversation'

  actions:
    add: ->
      @currentModel.save().then (record) =>
        @get('session').get('conversations').pushObject(record)
        @replaceWith('conversation.index', record)

    remove: ->
      @replaceWith('root')
      @store.deleteRecord(@currentModel)
      @get('session').get('conversations').removeObject(@currentModel)
      @currentModel.save().then (record) =>
        @store.set("convo:#{record.get('handle').toLowerCase()}", undefined)


  model: (params) ->
    @getConvoPromise(params.handle)

  renderTemplate: () ->
    @render(view: 'cloudsdale/Conversations/header', outlet: 'header')
    @_super()

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

Cloudsdale.ConversationIndexRoute = Cloudsdale.ConversationRoute.extend

  afterModel: (model) ->
    switch model.get('access')
      when undefined then @transitionTo('conversation.info', model)

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

Cloudsdale.ConversationInfoRoute = Cloudsdale.ConversationRoute.extend()

