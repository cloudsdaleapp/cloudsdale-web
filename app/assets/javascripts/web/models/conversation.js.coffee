Cloudsdale.Conversation = DS.Model.extend
  type:         DS.attr('string')
  handle:       DS.attr('string')
  access:       DS.attr('string')
  topic_id:     DS.attr('string')
  user_id:      DS.attr('string')
  user:         DS.belongsTo('Cloudsdale.User')
  topic:        DS.belongsTo('Cloudsdale.Topic', { polymorphic: true })

Cloudsdale.Conversation.reopenClass
  lookup: (id, record) ->
    this.all().some (item) -> record ||= item if item.get('handle') == id
    record = this.find(params.topic) unless record
    return record