Cloudsdale.MessagesFormView = Ember.View.extend

  tagName: 'form'
  classNames: ['new-message']
  templateName: 'messages_form'

  textArea: null

  didResize: (el) ->
    @get('parentView').adjustChildren()

  didInsertElement: ->
    view = this
    form = Ember.$(@get('element'))
    @set('textArea', form.find('textArea'))
    textArea = @get('textArea')

    form.on 'submit', (e) ->
      view.get('parentView.messagesListView').scrollToBottom()
      view.get('controller').send('saveMessage')
      e.preventDefault()
      return false

    textArea.autosize
      callback: (el) => @didResize(el)

    textArea.on 'keydown', (event) =>
      if (event.which == 13) and (event.shiftKey == false)
        event.preventDefault()

        if textArea.val().replace(/^[(\r\n|\n|\r)\s]+/ig,"") == ""
          textArea.val("")
          textArea.trigger('autosize.resize')
        else
          form.trigger('submit') unless textArea.val() == ""
          textArea.trigger('autosize.resize')
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
    form = Ember.$(@get('element'))
    form.off('submit')
    textArea = @get('textArea')
    textArea.trigger('autosize.destroy')
    textArea.off('keydown')