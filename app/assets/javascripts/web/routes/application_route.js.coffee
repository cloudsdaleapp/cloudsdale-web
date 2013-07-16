Cloudsdale.ApplicationRoute = Ember.Route.extend
  templateName: 'application'

  model: -> @extractSessionFromBody()

  setupController: (controller,model) ->
    controller.set('model',model)

  renderTemplate: ->
    this.render()

  extractSessionFromBody: ->
    payload = JSON.parse($('body').attr('session'))
    id      = payload['session']['id']
    store   = DS.get('defaultStore')
    adapter = store.adapterForType(Cloudsdale.Session)

    adapter.didFindRecord(store,Cloudsdale.Session,payload,id)

    $('body').attr('session',null)

    return window.session = Cloudsdale.Session.find(id)