Cloudsdale.Conversation = DS.Model.extend
  type:         DS.attr('string', { defaultValue: 'conversation' })
  handle:       DS.attr('string')
  access:       DS.attr('string', { defaultValue: 'requesting' })
  user:         DS.belongsTo('user')
  topic:        DS.belongsTo('topic', { polymorphic: true })

Cloudsdale.ConversationAdapter = DS.CloudsdaleAdapter.extend
  buildURL: (type, id) ->
    url = []
    url.push @get('host')
    url.push @get('namespace')
    url.push 'me/convos'
    url.push id if id
    return url.join("/") + ".json"

  # deleteRecord: (store, type, record) ->
  #   @ajax(this.buildURL(type.typeKey, id), "DELETE")

  # updateRecord: (store, type, record) ->
  #   @ajax(this.buildURL(type.typeKey, id), "PUT")

Cloudsdale.ConversationAdapter.create({})

Cloudsdale.ConversationSerializer = DS.CloudsdaleSerializer.extend({

  createAttributes:  ['topic']
  updateAttributes:  ['access', 'position']

})
