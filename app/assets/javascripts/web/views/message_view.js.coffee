Cloudsdale.MessageView = Ember.View.extend
  classNames:    ['message row']
  templateName:  'message'

  shouldScrollToMessage: false

  willInsertElement: () ->
    if @get('parentView').state == "inDOM"
      @set('shouldScrollToMessage', !@get('parentView').get('isReadingHistory'))

    @_super()

  didInsertElement: ->
    @get('parentView').scrollToBottom( force: @get('shouldScrollToMessage') )
    @set('shouldScrollToMessage', false)
    @_super()