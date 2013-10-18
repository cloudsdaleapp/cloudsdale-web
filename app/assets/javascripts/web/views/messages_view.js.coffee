Cloudsdale.MessagesView = Ember.View.extend
  templateName: 'messages'
  scrollOffset: 200
  desiredScroll: undefined

  isReadingHistory: () ->
    canvas   = @collection().outerHeight()
    scroll   = @collection()[0].scrollHeight
    location = @collection()[0].scrollTop
    return (scroll - location != canvas)

  isScrolledToTop: () ->
    return (0 + @scrollOffset) >= @scrollBody().scrollTop()

  didChangeCurrentMessage: ( () ->
    @focusTextArea()
  ).observes('controller.currentMessage')

  didResize: (textarea) -> @organizeLayers()

  didScroll: (view,e) ->
    distance = (
      @scrollBody()[0].scrollHeight - (@scrollBody().outerHeight() + @scrollOffset)
    ) - @scrollBody().scrollTop()

    @set('desiredScroll', distance) unless @isScrolledToTop()
    @get('controller').send('loadMore') if @isScrolledToTop()

  didInsertElement: ->
    @textArea().autosize
      callback: (el) => @didResize(el)

    @textArea().bind 'keydown', (event) =>
      if (event.which == 13) and (event.shiftKey == false)
        event.preventDefault()

        if @textArea().val().replace(/^[(\r\n|\n|\r)\s]+/ig,"") == ""
          @textArea().val("")
          @textArea().trigger('autosize.resize')
        else
          @form().trigger('submit') unless @textArea().val() == ""
          @textArea().trigger('autosize.resize')
        return false

      else if (event.which == 9)
        event.preventDefault()

        loc  = event.target.selectionStart
        val  = event.target.value
        before = val.substring(0, loc)
        after  = val.substring(loc, val.length)

        newLoc = loc + 2
        newVal = before + "  " + after

        event.target.value = newVal
        if event.target.createTextRange
          range = event.target.createTextRange()
          range.move('character', newLoc)
          range.select()
        else
          event.target.focus()
          event.target.setSelectionRange(newLoc, newLoc) if event.target.selectionStart

        return false

    @focusTextArea()

    @scrollBody().bind("scroll", (event) => @didScroll(this, event))

    # setTimeout((=> $(@scrollParent).trigger("scroll")), 200)

  willDestroyElement: ->
    @.$('form.new-message textarea').trigger('autosize.destroy')
    @textArea().unbind('keydown')
    @scrollBody().unbind("scroll")

  organizeLayers: ->
    @collection().css('bottom', @form().height())
    @scrollToBottom( force: true )

  scrollToBottom: (opts) ->
    opts ||= {}
    opts.force ||= false
    if opts.force or not @isReadingHistory()
      @collection().scrollTop(@collection()[0].scrollHeight)

  scrollToFromBottom: (distance, opts) ->
    opts ||= {}
    top = (@scrollBody()[0].scrollHeight - distance)
    @scrollBody().scrollTop(top)

  focusTextArea: ->
    if @state == "inDOM"
      @textArea().focus().select()

  scrollBody: () -> @collection()
  collection: () -> @.$('div.messages')
  form:       () -> @.$('form.new-message')
  textArea:   () -> @.$('form.new-message textarea')
