#= require ./store
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views
#= require_tree ./helpers
#= require_tree ./templates
#= require_tree ./routes
#= require ./router
#= require_self

$ ->
  extractSessionData()

extractSessionData = ->
  payload = JSON.parse($('body').attr('session'))
  id      = payload['session']['id']
  store   = DS.get('defaultStore')
  adapter = store.adapterForType(Cloudsdale.Session)

  adapter.didFindRecord(store,Cloudsdale.Session,payload,id)

  window.session      = Cloudsdale.Session.find(id)
  window.current_user = session.get('user')