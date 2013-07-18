Cloudsdale.Conversation = DS.Model.extend
  type:         DS.attr 'string'
  access:       DS.attr('string')
  user:         DS.belongsTo('Cloudsdale.User')
  topic:        DS.belongsTo('Cloudsdale.Topic', { polymorphic: true })
