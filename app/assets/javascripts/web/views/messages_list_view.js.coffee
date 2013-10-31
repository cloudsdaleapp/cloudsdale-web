get = Ember.get
set = Ember.set
fmt = Ember.String.fmt

Cloudsdale.MessagesListView = Ember.CollectionView.extend

  classNames: ['messages']

  content: null

  itemViewClass: Cloudsdale.MessageView

  height: ( (name, bottom) ->
    el = Ember.$(@get('element'))
    el.css(bottom: bottom) if bottom
    return el.outerHeight()
  ).property()

  scrollTop: null

  scrollHeightWas: 0
  scrollHeight: 0
  _scrollHeight: ( () ->
    Ember.run.scheduleOnce 'afterRender', this, () ->
      @set('scrollHeightWas', @get('scrollHeight'))
      @set('scrollHeight', @get('element').scrollHeight)

  ).observes('childViews.length')

  scrollOffset: ( () ->
    return 0
  ).property('scrollHeight')

  isReadingHistory: false
  _isReadingHistory: ( () ->
    @set('isReadingHistory', (@get('scrollHeight') - @get('scrollTop')) != @get('height'))
  ).observes('scrollTop', 'height', 'scrollHeight')

  isScrolledToTop: false
  _isScrolledToTop: ( () ->
    @set('isScrolledToTop', (@get('scrollOffset') >= @get('scrollTop')))
  ).observes('scrollOffset', 'scrollTop')

  _didChangeScrollHeight: ( () ->
    @didChangeScrollHeight(@get('scrollHeight'), @get('scrollHeightWas'))
  ).observes('scrollHeight')
  didChangeScrollHeight: (now, before) ->
    if @get('isReadingHistory')
      delta = (now + @get('scrollOffset')) - before
      @scrollTo(delta)

  didInsertElement: ->
    view = this
    el = @get('element')

    if callback = @get('parentView').didInsertChild
      callback(@get('parentView'), this)

    Ember.$(el).on('scroll', (event) ->
      view.didScroll(el, event)
      if view.get('isScrolledToTop')
        event.preventDefault()
        return false
    )

    @_super()

  didScrollTop: ( () ->
    @get('controller').send('loadMore') if @get('isScrolledToTop')
  ).observes('isScrolledToTop')

  didScroll: (el, e) ->
    @set('scrollTop', @get('element.scrollTop'))
    # console.log @set('scrollHeight', el.out)
    # distance = (
    #   @scrollBody()[0].scrollHeight - (@scrollBody().outerHeight() + @scrollOffset)
    # ) - @scrollBody().scrollTop()

    # @set('desiredScroll', distance) unless @isScrolledToTop()
    # @get('controller').send('loadMore') if @isScrolledToTop()

  willDestroyElement: ->
    el = @get('element')
    Ember.$(el).off('scroll')

  scrollTo: (y) ->
    el = @get('element')
    el.scrollTop = y

  scrollToBottom: ->
    @scrollTo(@get('scrollHeight'))

  scrollToTop: ->
    @scrollTo(0)

  createChildView: (viewClass, attrs) ->
    attrs.controller = attrs.content
    delete attrs.content
    return @_super(viewClass, attrs)