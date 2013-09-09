Cloudsdale.Cloud = DS.Model.extend
  type:        DS.attr('string')
  displayName: DS.attr('string')
  avatar:      DS.attr('string')
  shortName:   DS.attr('string')

  participantCount: DS.attr('number')

  handle: (-> @get('shortName').toLowerCase() ).property('shortName')

Cloudsdale.CloudAdapter = DS.CloudsdaleAdapter.extend({})