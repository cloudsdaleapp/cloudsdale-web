Cloudsdale.GazeView = Ember.View.extend
  templateName: 'gaze'
  scrollParent: '.main'
  scrollOffset: 50

  didInsertElement: ->
    view = this
    setTimeout =>
      $(@scrollParent).on("scroll", (e) -> view.didScroll(view,e))
      $(@scrollParent).trigger("scroll")
    , 3000

  didScroll: (view,e) ->
    @get('controller').send('more') if @isScrolledToBottom()


  willDestroyElement: () ->
    $(@scrollParent).off("scroll")


  isScrolledToBottom: () ->
    distanceToBottom = $(@scrollParent)[0].scrollHeight - $(document).height()
    top = $(@scrollParent).scrollTop()
    return (top + @scrollOffset) >= distanceToBottom
