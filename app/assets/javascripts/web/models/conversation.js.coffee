Cloudsdale.Conversation = DS.Model.extend
  type:         DS.attr('string')
  handle:       DS.attr('string')
  access:       DS.attr('string')
  topic_id:     DS.attr('string')
  user_id:      DS.attr('string')
  user:         DS.belongsTo('Cloudsdale.User')
  topic:        DS.belongsTo('Cloudsdale.Topic', { polymorphic: true })
