Cloudsdale.Conversation = DS.Model.extend
  type:         DS.attr('string')
  handle:       DS.attr('string')
  access:       DS.attr('string')
  user:         DS.belongsTo('user')
  topic:        DS.belongsTo('topic', { polymorphic: true })

Cloudsdale.Conversation.reopenClass
  lookup: (store, id, record) ->
    store.all('conversation').some (convo) =>
      record ||= store.fetch('conversation', convo) if convo.get('handle') == id
    record ||= store.find('conversation', id)
    return record

Cloudsdale.ConversationAdapter = DS.CloudsdaleAdapter.extend
  buildURL: (type, id) ->
    url = []
    url.push @get('host')
    url.push @get('namespace')
    url.push 'me/convos'
    url.push id if id
    return url.join("/") + ".json"