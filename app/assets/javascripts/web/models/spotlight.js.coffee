Cloudsdale.Spotlight = DS.Model.extend
  text:          DS.attr('string')
  category:      DS.attr('string')
  target:        DS.belongsTo('target', { polymorphic: true })

Cloudsdale.SpotlightAdapter = DS.CloudsdaleAdapter.extend({})