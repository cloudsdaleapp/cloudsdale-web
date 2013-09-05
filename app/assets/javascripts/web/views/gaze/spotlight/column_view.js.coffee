Cloudsdale.Gaze ||= Ember.Namespace.create()
Cloudsdale.Gaze.Spotlight ||= Ember.Namespace.create()
Cloudsdale.Gaze.Spotlight.ColumnView = Ember.View.extend(

  classNames: ['columns']
  tagName: 'div'
  columnType: null

  classNameBindings: ['largeClassBinding', 'smallClassBinding']

  largeClassBinding: ( ()->
    if (@get('_parentView._parentView.contentIndex') % 3) == 7
      return switch @get('columnType')
        when 'card'   then 'large-9'
        when 'stats'  then 'large-9'
        when 'avatar' then 'large-3'
        else 'large-12'
    else
      return switch @get('columnType')
        when 'card'   then 'large-12'
        when 'stats'  then 'large-8'
        when 'avatar' then 'large-4'
        else 'large-12'

  ).property("_parentView._parentView.contentIndex")

  smallClassBinding: ( ()->
    if (@get('_parentView._parentView.contentIndex') % 3) == 7
      return switch @get('columnType')
        when 'card'   then 'small-12'
        when 'stat'   then 'small-4'
        when 'avatar' then 'small-4'
        else 'large-6'
    else
      return switch @get('columnType')
        when 'card'   then 'small-12'
        when 'stats'  then 'small-9'
        when 'avatar' then 'small-3'
        else 'small-12'
  ).property("_parentView._parentView.contentIndex")

)