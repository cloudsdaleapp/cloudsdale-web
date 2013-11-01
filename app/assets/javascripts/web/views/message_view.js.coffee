Cloudsdale.MessageView = Ember.View.extend

  classNames:    ['message']
  classNameBindings: ['lastMessageClass', 'firstMessageClass', 'hasActions']

  templateName:  'message'

  shouldScrollToBottom: false

  willInsertElement: () ->
    parent = @get('parentView')
    @set('shouldScrollToBottom', !parent.get('isReadingHistory')) if parent.state == 'inDOM'
    @_super()

  didInsertElement: ->
    return @_super() unless @state == 'inDOM'

    el = @get('element')
    view = this
    parent = view.get('parentView')

    if callback = @get('parentView').didInsertChild
      callback(this)

    if @get('shouldScrollToBottom') && Ember.$(el).is(':last-child')
      Ember.run.scheduleOnce('afterRender', parent, () ->
        parent.scrollToBottom() if parent.state == 'inDOM'
      )

    element = Ember.$(el)
    if element.is(':first-child')
      previousMark = element.nextAll('.message-mark')

      previousMark.find('.message-box').stop().css(
        'background-color' : '#63a0d0'
      ).animate({
        backgroundColor: '#FFFFFF'
      }, 1500)

      previousMark.removeClass('message-mark')
      element.addClass('message-mark')

    unless @get('controller.isFirst')
      @.$().prevAll('.message').first().removeClass('message-last')

    unless @get('controller.isLast')
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
    return @_super() unless @state == 'inDOM'

    @.$('a[internal]').off('click')

    if @get('controller.isFirst')
      @.$().nextAll('.message').first().addClass('message-first')

    if @get('controller.isLast')
      @.$().prevAll('.message').first().addClass('message-last')

    @_super()

  lastMessageClass: ( () ->
    if @get('controller.isLast') then "message-last" else ""
  ).property('controller.isLast')

  firstMessageClass: ( () ->
    if @get('controller.isFirst') then "message-first" else ""
  ).property('controller.isFirst')

  hasActions: ( () ->
    if @get('context.canManipulate') then 'message-with-actions' else ''
  ).property('context.canManipulate')
