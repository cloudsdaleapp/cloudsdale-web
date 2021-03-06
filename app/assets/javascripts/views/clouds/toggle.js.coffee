class Cloudsdale.Views.CloudsToggle extends Backbone.View

  template: JST['clouds/toggle']

  model: 'cloud'
  tagName: 'li'
  className: 'sidebar-item'

  events: {
    'click a' : 'activate'
  }

  initialize: ->

    @active = false

    @fetchNotifications()

    @render()
    @bindEvents()

    setTimeout =>
      @refreshGfx()
    , 10

  render: ->
    $(@el).html(@template(model: @model)).attr('data-entity-id',@model.id)
    this

  bindEvents: ->

    @model.on 'change', => @refreshGfx()

    $(@el).bind 'page:show', (event,page_id) =>
      if page_id == @model.id
        @active = true
        $(@el).addClass('active')
        @clearNotifications()
      else
        @active = false
        $(@el).removeClass('active')

    $(@el).bind "clouds:leave", (event,cloud) =>
      if cloud.id == @model.id
        @unbindEvents()
        $(@el).remove()

    $(@el).bind "clouds:disable", (event,cloud) =>
      if cloud.id == @model.id
        @disable()

    $(@el).bind "clouds:enable", (event,cloud) =>
      if cloud.id == @model.id
        @enable()

    nfc.on "#{@model.type}s:#{@model.id}:chat:messages", (payload) =>
      @addNotification()

    $(window).focus =>
      if @active
        $(@el).addClass('active')
        @clearNotifications()

    $(window).blur => $(@el).removeClass('active')
    $(window).bind 'resizestop', => @refreshGfx()

  unbindEvents: ->
    $(@el).unbind('page:show').unbind('clouds:leave')
    .unbind('clouds:disable').unbind('clouds:enable')
    nfc.off("#{@model.type}s:#{@model.id}:chat:messages")

  refreshGfx: ->
    @.$('.sidebar-item-notification').html("#{@notifications}")

    if @notifications >= 1
      $(@el).addClass('with-notifications')
      @.$('.sidebar-item-name').css('margin-right',@.$('.sidebar-item-notification').outerWidth() + 10)
    else
      $(@el).removeClass('with-notifications')

    @.$('.sidebar-item-avatar').css('background-image',"url(#{@model.get('avatar').preview})")
    @.$('.sidebar-item-name').text(@model.get('name')).truncate()
    @.$('.toggle-link').attr('href',@model.link())

    if session.get('user').bans.activeOn(@model).length >= 1
      @disable()

  activate: ->
    $("body").removeClass('with-expanded-cloudbar')
    true

  disable: ->
    $(@el).addClass('disabled')

  enable: ->
    $(@el).removeClass('disabled')

  # Clears Cloud of all notifications and refreshes the notification plate
  clearNotifications: ->
    subtractGlobalNotification(@notifications)
    @notifications = 0
    @setNotifications()

  # Appends a notification and refreshes the notification plate unless the Cloud is currently active
  addNotification: ->
    if @active == false or ((@active == true) and (document.window_focus == false))
      addGlobalNotification(1)
      @notifications += 1
      @setNotifications()

  fetchNotifications: ->
    unless @notifications
      n = localStorage["cloud:#{@model.id}:notifications"]
      if typeof n is 'string'
        @notifications = parseInt(n)
      else
        @notifications = n

      addGlobalNotification(@notifications)

    @refreshGfx()

  setNotifications: ->
    localStorage["cloud:#{@model.id}:notifications"] = @notifications

    @refreshGfx()

