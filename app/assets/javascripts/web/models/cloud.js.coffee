Cloudsdale.Cloud = DS.Model.extend

  type:        DS.attr('string', defaultValue: 'cloud')
  displayName: DS.attr('string')
  description: DS.attr('string')
  avatar:      DS.attr('string')
  shortName:   DS.attr('string')

  participantCount: DS.attr('number')

  handle: (->
    @get('shortName').toLowerCase() if @get('shortName')
  ).property('shortName')

Cloudsdale.CloudAdapter = DS.CloudsdaleAdapter.extend({})