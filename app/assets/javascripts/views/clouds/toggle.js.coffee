class Cloudsdale.Views.CloudsToggle extends Backbone.View
 
  template: JST['clouds/toggle']
  
  model: 'cloud'
  tagName: 'li'
  className: 'cloud-toggle'
  
  events: {
    'click a' : 'activate'
  }
  
  initialize: ->
    
    @active = false
    
    @fetchNotifications()
    
    @render()
    @refreshGfx()
    @bindEvents()
  
  render: ->
    $(@el).html(@template(model: @model)).attr('data-cloud-id',@model.id)
    this
  
  bindEvents: ->
    $(@el).bind 'page:show', (event,page_id) =>
      if page_id == @model.id
        @active = true
        $(@el).addClass('active') 
      else
        @active = false
        $(@el).removeClass('active') 
    
    $(@el).bind "clouds:leave", (event,cloud) =>
      if cloud.id == @model.id
        @unbindEvents()
        $(@el).remove()
        
    nfc.on "#{@model.type}s:#{@model.id}:chat:messages", (payload) =>
      @addNotification()
      
    $(window).focus =>
      if @active
        $(@el).addClass('active')
        @clearNotifications()
    
    $(window).blur =>
      $(@el).removeClass('active')
  
  unbindEvents: ->
    $(@el).unbind('page:show').unbind('clouds:leave')
    nfc.off("#{@model.type}s:#{@model.id}:chat:messages")
    
  refreshGfx: ->
    @.$('.cloud-toggle-notification').html("#{@notifications}")
    if @notifications >= 1
      $(@el).addClass('with-notifications')
    else
      $(@el).removeClass('with-notifications')
  
  activate: ->
    Backbone.history.navigate("/clouds/#{@model.id}",true)
    false
  
  
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
      n = $.cookie("cloud:#{@model.id}:notifications")
      if typeof n is 'string'
        @notifications = parseInt(n)
      else
      
    @refreshGfx()
    
  setNotifications: ->
    $.cookie "cloud:#{@model.id}:notifications", @notifications, 
      expires: 365
      path: "/"    
    
    @refreshGfx()
    