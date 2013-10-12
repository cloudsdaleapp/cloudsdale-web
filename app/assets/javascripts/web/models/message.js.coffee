Cloudsdale.Message = DS.Model.extend

  type:      DS.attr('string', defaultValue: 'message')
  device:    DS.attr('string', defaultValue: 'desktop')
  content:   DS.attr('string')
  createdAt: DS.attr('date')
  updatedAt: DS.attr('date')

  author:    DS.belongsTo('user')
  topic:     DS.belongsTo('topic', { polymorphic: true })

  timestamp: ( () ->
    @get('createdAt').getTime() if @get('createdAt')
  ).property('createdAt')

Cloudsdale.MessageAdapter = DS.CloudsdaleAdapter.extend()
Cloudsdale.MessageAdapter.create()

Cloudsdale.MessageSerializer = DS.CloudsdaleSerializer.extend({

  createAttributes:  ['content', 'topic', 'device']
  updateAttributes:  ['content']

})
