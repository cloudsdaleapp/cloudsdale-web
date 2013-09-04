Cloudsdale.User = DS.Model.extend
  email:         DS.attr('string')
  displayName:   DS.attr('string')
  username:      DS.attr('string')
  avatar:        DS.attr('string')
  suspended:     DS.attr('boolean')
  readTerms:     DS.attr('boolean')
  defaultAvatar: DS.attr('boolean')

  handle: (-> @get('username').toLowerCase() ).property('username')

Cloudsdale.UserAdapter = DS.CloudsdaleAdapter.extend({})