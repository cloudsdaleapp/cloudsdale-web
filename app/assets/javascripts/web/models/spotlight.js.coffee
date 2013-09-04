Cloudsdale.Spotlight = DS.Model.extend
  text:          DS.attr('string')
  category:      DS.attr('string')
  target:        DS.belongsTo('target', { polymorphic: true })

  targetType:    DS.attr('string')

Cloudsdale.SpotlightAdapter = DS.CloudsdaleAdapter.extend({})