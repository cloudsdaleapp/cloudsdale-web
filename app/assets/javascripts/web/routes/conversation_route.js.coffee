Cloudsdale.ConversationRoute = Ember.Route.extend

  controllerName: 'conversation'

  actions:
    add: ->
      @currentModel.save().then (record) =>
        @get('session').get('conversations').pushObject(record)
        @replaceWith('messages', record)

    remove: ->
      @replaceWith('root')
      @store.deleteRecord(@currentModel)
      @get('session').get('conversations').removeObject(@currentModel)
      @currentModel.save().then (record) =>
        @store.set("convo:#{record.get('handle').toLowerCase()}", undefined)


  model: (params) ->
    @getConvoPromise(params.handle)

  renderTemplate: () ->
    @render('header.conversation', outlet: 'header')
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
      Ember.Logger.debug("Fetching #{key} from server")
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

  setupController: (controller, model) ->
    topic = model.get('topic')
    user  = model.get('user')

    messages = @controllerFor('messages')
    messages.set('model', @messages(topic))

    controller.set('model', model)
    controller.set('topic', topic)
    controller.set('user',  user)

    controller.set('messages', messages)

    @_super(controller, model)

Cloudsdale.ConversationInfoRoute  = Cloudsdale.ConversationRoute.extend()
Cloudsdale.ConversationShareRoute = Cloudsdale.ConversationRoute.extend()

