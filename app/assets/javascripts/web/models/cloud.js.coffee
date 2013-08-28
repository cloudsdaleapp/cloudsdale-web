Cloudsdale.Cloud = DS.Model.extend
  type:        DS.attr 'string'
  displayName: DS.attr 'string'
  avatar:      DS.attr 'string'
  shortName:   DS.attr 'string'

  handle: (-> @get('shortName').toLowerCase() ).property('handle')
