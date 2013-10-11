Cloudsdale.Message = DS.Model.extend

  device:  DS.attr('string')
  content: DS.attr('string')
  author:  DS.belongsTo('user')
  topic:   DS.belongsTo('topic')

Cloudsdale.MessageAdapter = DS.CloudsdaleAdapter.extend()