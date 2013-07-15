Cloudsdale.Session = DS.Model.extend
  conversations: DS.hasMany   'Cloudsdale.Conversation'
  user:          DS.belongsTo 'Cloudsdale.User'
