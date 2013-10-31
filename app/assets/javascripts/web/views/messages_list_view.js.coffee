get = Ember.get
set = Ember.set
fmt = Ember.String.fmt

Cloudsdale.MessagesListView = Ember.CollectionView.extend

  classNames: ['messages']

  content: null

  itemViewClass: Cloudsdale.MessageView

  createChildView: (viewClass, attrs) ->
    attrs.controller = attrs.content
    delete attrs.content
    return @_super(viewClass, attrs)