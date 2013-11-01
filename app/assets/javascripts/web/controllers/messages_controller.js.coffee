Cloudsdale.MessagesController = Ember.ArrayController.extend

  content: Ember.A([])

  sortProperties: ['timestamp']
  sortAscending: true

  groupProperty: 'model.author.id'
  groupByMismatch: true

  itemController: 'message'

  insertItemSorted: (item) ->
    arrangedContent = @get("arrangedContent")
    length = arrangedContent.get("length")
    idx = @_binarySearch(item, 0, length)

    ary = arrangedContent.insertAt(idx, item)

    curr = @objectAt(idx)
    prev = @objectAt(idx - 1)
    next = @objectAt(idx + 1)
    @groupBy(prev, curr, next) if curr

  groupBy: (prev, curr, next) ->

    groupProperty = @get('groupProperty')
    groupByMismatch = @get('groupByMismatch')

    if prev
      unlikePrev = curr.get(groupProperty) == prev.get(groupProperty)
      unlikePrev = if groupByMismatch then (!unlikePrev) else (unlikePrev)
      prev.set('content.isLast', unlikePrev)
      curr.set('content.isFirst', unlikePrev)
    else
      curr.set('content.isFirst', true)

    if next
      unlikeNext = curr.get(groupProperty) == next.get(groupProperty)
      unlikeNext = if groupByMismatch then (!unlikeNext) else (unlikeNext)
      curr.set('content.isLast', unlikeNext)
      next.set('content.isFirst', unlikeNext)
    else
      curr.set('content.isLast', true)

