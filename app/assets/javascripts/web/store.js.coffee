# http://emberjs.com/guides/models/defining-a-store/

DS.CloudsdaleAdapter = DS.RESTAdapter.extend
  url: 'http://api.cloudsdale.dev/v2'
  buildURL: (record, suffix) ->
    recordNs = switch record
      when 'conversation' then 'me/convo'
      else record

    return this._super(recordNs, suffix) + ".json"

  ajax: (url, type, hash) ->
    hash ||= {}
    hash.xhrFields =
      withCredentials: true

    this._super(url, type, hash)

DS.CloudsdaleAdapter.configure 'Cloudsdale.Cloud', {
  alias: 'cloud'
}

Cloudsdale.Store = DS.Store.extend
  adapter: DS.CloudsdaleAdapter.create()

