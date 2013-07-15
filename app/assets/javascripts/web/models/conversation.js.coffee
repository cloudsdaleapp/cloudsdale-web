Cloudsdale.Conversation = DS.Model.extend
  user:          DS.belongsTo 'Cloudsdale.User'
  access:        DS.attr 'string'
  topic:         DS.belongsTo 'Cloudsdale.Cloud'
