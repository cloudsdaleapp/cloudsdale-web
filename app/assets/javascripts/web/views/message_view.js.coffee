Cloudsdale.MessageView = Ember.View.extend
  classNames:    ['message']
  classNameBindings: ['isLastMessage', 'isFirstMessage', 'hasActions']

  templateName:  'message'

  shouldScrollToMessage: false

  willInsertElement: () ->
    if @get('parentView').state == "inDOM"
      distance = @get('parentView.desiredScroll')
      @get('parentView').scrollToFromBottom(distance) if distance
      @set('shouldScrollToMessage', !@get('parentView').isReadingHistory())

    @_super()

  didInsertElement: ->
    @get('parentView').scrollToBottom( force: @get('shouldScrollToMessage') ) if @get('parentView')
    setTimeout =>
      @get('parentView').scrollToBottom( force: @get('shouldScrollToMessage') ) if @get('parentView')
      @set('shouldScrollToMessage', false)
    , 100

    if @get('context').get('hasSameAuthorAsPrevious')
      @.$().prevAll('.message').first().removeClass('message-last')

    if @get('context').get('hasSameAuthorAsNext')
      @.$().nextAll('.message').first().removeClass('message-first')

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

    unless @get('context').get('hasSameAuthorAsPrevious')
      @.$().nextAll('.message').first().addClass('message-first')

    unless @get('context').get('hasSameAuthorAsNext')
      @.$().prevAll('.message').first().addClass('message-last')

    @_super()

  isLastMessage: ( () ->
    if not @get('context').get('hasSameAuthorAsNext') then "message-last" else ""
  ).property('messagePositions')

  isFirstMessage: ( () ->
    if not @get('context').get('hasSameAuthorAsPrevious') then "message-first" else ""
  ).property('messagePositions')

  hasActions: ( () ->
    if @get('context.canManipulate') then 'message-with-actions' else ''
  ).property('context.canManipulate')
