Cloudsdale.Spotlight = DS.Model.extend
  text:          DS.attr('string')
  category:      DS.attr('string')
  target:        DS.belongsTo('Cloudsdale.Topic', { polymorphic: true })