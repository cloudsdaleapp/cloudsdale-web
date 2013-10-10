Cloudsdale.Handle = DS.Model.extend
  type:          DS.attr('string')
  identifiable:  DS.belongsTo('identifiable', { polymorphic: true })

Cloudsdale.HandleAdapter = DS.CloudsdaleAdapter.extend
  buildURL: (type, id) ->
    url = []
    url.push @get('host')
    url.push @get('namespace')
    url.push 'handle'
    url.push id.toLowerCase() if id
    return url.join("/") + ".json"

Cloudsdale.HandleAdapter.create()

Cloudsdale.HandleSerializer = DS.CloudsdaleSerializer.extend

  extractSingle: (store, type, payload, id, requestType) ->
    @_super(store, type, payload, id, requestType)

Cloudsdale.HandleSerializer.create()