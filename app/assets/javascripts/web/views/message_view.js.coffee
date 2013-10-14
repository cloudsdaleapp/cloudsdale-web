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

    @.$('a[internal]').on('click', (e) =>
      event.preventDefault()
      @get('container')
      .lookup('router:main')
      .transitionTo(event.target.pathname)
      return false
    )

    @_super()

  willDestroyElement: ->
    @.$('a[internal]').off('click')
    @_super()