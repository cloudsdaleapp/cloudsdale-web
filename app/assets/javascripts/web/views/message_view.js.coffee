Cloudsdale.MessageView = Ember.View.extend
  classNames:    ['message']
  classNameBindings: ['isLastMessage', 'isFirstMessage']

  templateName:  'message'

  shouldScrollToMessage: false

  willInsertElement: () ->
    if @get('parentView').state == "inDOM"
      distance = @get('parentView.desiredScroll')
      @get('parentView').scrollToFromBottom(distance) if distance
      @set('shouldScrollToMessage', !@get('parentView').isReadingHistory())

    @_super()

  didInsertElement: ->
    @get('parentView').scrollToBottom( force: @get('shouldScrollToMessage') )
    setTimeout =>
      @get('parentView').scrollToBottom( force: @get('shouldScrollToMessage') )
      @set('shouldScrollToMessage', false)
    , 100

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

  isLastMessage: ( () ->
    if not @get('context').get('hasSameAuthorAsNext') then "message-last" else ""
  ).property('messagePositions')

  isFirstMessage: ( () ->
    if not @get('context').get('hasSameAuthorAsPrevious') then "message-first" else ""
  ).property('messagePositions')
