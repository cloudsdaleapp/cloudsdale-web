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
