Cloudsdale.MessagesView = Ember.View.extend
  templateName: 'messages'

  didInsertElement: ->

    @textArea().autosize
      callback: (el) => @didResize(el)

    @textArea().bind 'keydown', (event) =>
      if (event.which == 13) and (event.shiftKey == false)
        event.preventDefault()
        @form().trigger('submit')
        return false

    @get('context').addArrayObserver('arrangedContent', {
      didChange:  (observedObj, start, removeCount, addCount) => @scrollToBottom()
      willChange: (observedObj, start, removeCount, addCount) => @scrollToBottom()
    })

    # @get('context').addObserver('currentMessageChanges', 'currentMessage', {
    #   didChange: => console.log "new message!"
    # })

  willDestroyElement: ->
    console.log "what?"
    @.$('form.new-message textarea').trigger('autosize.destroy')
    @textArea().unbind('keydown')
    @get('context').removeArrayObserver('arrangedContent')

  didResize: (textarea) -> @organizeLayers()

  organizeLayers: ->
    @collection().css('bottom', @form().height())
    @scrollToBottom( force: true )

  isReadingHistory: ->
    canvas   = @collection().outerHeight()
    scroll   = @collection()[0].scrollHeight
    location = @collection()[0].scrollTop

    (scroll - location != canvas)

  scrollToBottom: (opts) ->
    opts ||= {}
    opts.force ||= false
    if opts.force or not @isReadingHistory()
      setTimeout =>
        @collection().scrollTop(@collection()[0].scrollHeight)
      , 0

  collection: () -> @.$('div.messages')
  form: () -> @.$('form.new-message')
  textArea: () -> @.$('form.new-message textarea')