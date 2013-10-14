Cloudsdale.MessagesView = Ember.View.extend
  templateName: 'messages'

  isReadingHistory: ( () ->
    canvas   = @collection().outerHeight()
    scroll   = @collection()[0].scrollHeight
    location = @collection()[0].scrollTop

    return (scroll - location != canvas)
  ).property()

  didInsertElement: ->

    @textArea().autosize
      callback: (el) => @didResize(el)

    @textArea().bind 'keydown', (event) =>
      if (event.which == 13) and (event.shiftKey == false)
        event.preventDefault()
        @form().trigger('submit')
        return false

  willDestroyElement: ->
    @.$('form.new-message textarea').trigger('autosize.destroy')
    @textArea().unbind('keydown')

  didResize: (textarea) -> @organizeLayers()

  organizeLayers: ->
    @collection().css('bottom', @form().height())
    @scrollToBottom( force: true )

  scrollToBottom: (opts) ->
    opts ||= {}
    opts.force ||= false
    if opts.force or not @get('isReadingHistory')
      @collection().scrollTop(@collection()[0].scrollHeight)

  collection: () -> @.$('div.messages')
  form: () -> @.$('form.new-message')
  textArea: () -> @.$('form.new-message textarea')