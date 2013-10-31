Cloudsdale.MessageView = Ember.View.extend

  classNames:    ['message']
  classNameBindings: ['isLastMessage', 'isFirstMessage', 'hasActions']

  templateName:  'message'

  shouldScrollToMessage: false

  willInsertElement: () ->
    if @get('parentView.parentView').state == "inDOM"
      distance = @get('parentView.parentView.desiredScroll')
      @get('parentView.parentView').scrollToFromBottom(distance) if distance
      @set('shouldScrollToMessage', !@get('parentView.parentView').isReadingHistory())

    @_super()

  didInsertElement: ->

    @get('parentView.parentView').scrollToBottom( force: @get('shouldScrollToMessage') ) if @get('parentView.parentView')
    setTimeout =>
      @get('parentView.parentView').scrollToBottom( force: @get('shouldScrollToMessage') ) if @get('parentView.parentView')
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

    unless @get('context.hasSameAuthorAsPrevious')
      @.$().nextAll('.message').first().addClass('message-first')

    unless @get('context.hasSameAuthorAsNext')
      @.$().prevAll('.message').first().addClass('message-last')

    @_super()

  isLastMessage: ( () ->
    if not @get('context.hasSameAuthorAsNext') then "message-last" else ""
  ).property('messagePositions')

  isFirstMessage: ( () ->
    if not @get('context.hasSameAuthorAsPrevious') then "message-first" else ""
  ).property('messagePositions')

  hasActions: ( () ->
    if @get('context.canManipulate') then 'message-with-actions' else ''
  ).property('context.canManipulate')
