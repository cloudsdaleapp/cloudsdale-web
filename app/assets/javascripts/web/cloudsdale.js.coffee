#= require ./store
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views
#= require_tree ./templates
#= require_tree ./routes
#= require ./router
#= require_self

Ember.Application.initializer

  name: "session"

  initialize: (container, application) ->

    preloadEl  = 'body'
    sessionKey = 'session'
    userKey    = 'user'

    payload = JSON.parse($(preloadEl).attr(sessionKey))
    $(preloadEl).attr(sessionKey,null)

    record_id = payload[sessionKey].id

    store      = container.lookup('store:main')
    factory    = store.modelFor(sessionKey)
    serializer = store.serializerFor(sessionKey)

    store.push(factory,serializer.extractSingle(store, factory, payload))

    session = store.find(sessionKey, payload[sessionKey].id)
    user    = store.find(userKey,    payload[sessionKey][userKey].id)

    container.typeInjection('adapter', 'store', 'store:main')

    container.register("#{sessionKey}:main", session, { instantiate: false, singleton: true })
    container.typeInjection('controller',  sessionKey, "#{sessionKey}:main")
    container.typeInjection('route',       sessionKey, "#{sessionKey}:main")
    container.typeInjection('view',        sessionKey, "#{sessionKey}:main")

    container.register("#{userKey}:current", user, { instantiate: false })
    container.typeInjection('controller', 'currentUser', "#{userKey}:current")
    container.typeInjection('route',      'currentUser', "#{userKey}:current")
    container.typeInjection('view',       'currentUser', "#{userKey}:current")