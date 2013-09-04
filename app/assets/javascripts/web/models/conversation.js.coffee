Cloudsdale.Conversation = DS.Model.extend
  type:         DS.attr('string')
  handle:       DS.attr('string')
  access:       DS.attr('string')
  user:         DS.belongsTo('user')
  topic:        DS.belongsTo('topic', { polymorphic: true })

Cloudsdale.Conversation.reopenClass
  lookup: (store, id, record) ->
    store.all('conversation').some (convo) =>
      record ||= convo if convo.get('handle') == id
    record ||= this.find(params.topic)
    return record

Cloudsdale.ConversationAdapter = DS.CloudsdaleAdapter.extend({})