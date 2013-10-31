Cloudsdale.MessagesView = Ember.ContainerView.extend

  scrollOffset: 200
  desiredScroll: undefined

  childViews: ['messagesListView', 'messagesFormView']

  messagesListView: Cloudsdale.MessagesListView
  messagesFormView: Cloudsdale.MessagesFormView

  didInsertElement: ->
    @get('messagesListView').set('controller', @controller)
    @get('messagesListView').set('content', @controller)

    @get('messagesFormView').set('controller', @controller)
    @get('messagesFormView').set('content', @controller)

  # didChangeCurrentMessage: ( () ->
  #   @focusTextArea()
  # ).observes('controller.currentMessage')

  adjustChildren: ->
    return unless @childrenAreinDOM()

    list = Ember.$(@get('messagesListView.element'))
    form = Ember.$(@get('messagesFormView.element'))

    willScrollList = @get('messagesListView.isReadingHistory')

    @set('messagesListView.height', form.outerHeight())
    @get('messagesListView').scrollToBottom() unless willScrollList

  childrenAreinDOM: ->
    @get('messagesListView').state == 'inDOM' && @get('messagesFormView').state == 'inDOM'

  # focusTextArea: ->
  #   if @state == "inDOM"
  #     @textArea().focus().select()

  # scrollBody: () -> @collection()
  # collection: () -> @.$('div.messages')
  # form:       () -> @.$('form.new-message')
  # textArea:   () -> @.$('form.new-message textarea')
