# http://emberjs.com/guides/models/defining-a-store/
DS.CloudsdaleAdapter = DS.RESTAdapter.extend
  url: 'http://api.cloudsdale.dev/v2'
  buildURL: (record, suffix) ->
    this._super(record, suffix) + ".json"

DS.CloudsdaleAdapter.configure 'Cloudsdale.Cloud'
  alias: 'cloud'

Cloudsdale.Store = DS.Store.extend
  adapter: DS.CloudsdaleAdapter.create()

