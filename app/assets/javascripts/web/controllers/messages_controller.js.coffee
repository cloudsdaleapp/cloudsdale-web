Cloudsdale.MessagesController = Ember.ArrayController.extend
  content: Ember.A([])

  sortProperties: ['timestamp']
  sortAscending: true

  itemController: 'message'

  indexOf: (object, startAt) ->
    idx = undefined
    len = @get("length")
    startAt = 0  if startAt is `undefined`
    startAt += len  if startAt < 0
    idx = startAt

    while idx < len
      return idx  if @get('arrangedContent').objectAt(idx) is object
      idx++
    return -1

  before: ( (object) ->
    idx = @indexOf(object)
    obj = @objectAt(idx - 1)
    if obj then obj.get('model') else undefined
  )