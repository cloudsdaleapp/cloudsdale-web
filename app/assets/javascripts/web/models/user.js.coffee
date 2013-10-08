Cloudsdale.User = DS.Model.extend
  type:          DS.attr('string')
  email:         DS.attr('string')
  displayName:   DS.attr('string')
  username:      DS.attr('string')
  avatar:        DS.attr('string')
  suspended:     DS.attr('boolean')
  readTerms:     DS.attr('boolean')
  defaultAvatar: DS.attr('boolean')

  handle: (->
    @get('username').toLowerCase() if @get('username')
  ).property('username')

Cloudsdale.UserAdapter = DS.CloudsdaleAdapter.extend({})