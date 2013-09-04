Cloudsdale.Gaze ||= Ember.Namespace.create()
Cloudsdale.Gaze.Spotlight ||= Ember.Namespace.create()
Cloudsdale.Gaze.Spotlight.ColumnView = Ember.View.extend(

  classNames: ['small-12','columns']
  tagName: 'div'
  columnType: null

  classNameBindings: ['sizeClassBinding', 'centeredClassBinding']

  sizeClassBinding: ( ()->
    if (@get('_parentView._parentView.contentIndex') % 3) == 2
      return switch @get('columnType')
        when 'info' then 'large-8'
        when 'avatar' then 'large-4'
        else 'large-6'
    else
      return switch @get('columnType')
        when 'avatar' then 'large-10'
        else 'large-12'
  ).property("_parentView._parentView.contentIndex")

  centeredClassBinding: ( ()->
    if (@get('_parentView._parentView.contentIndex') % 3) != 2
      return switch @get('columnType')
        when 'avatar' then 'large-centered'
        else null
  ).property("_parentView._parentView.contentIndex")


)