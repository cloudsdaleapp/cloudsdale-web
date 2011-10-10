class Sidebar

  constructor: (args) ->
    @frame = $(args.frame)
    @trigger = $(args.trigger)
    @faye = args.faye_client
    @name = args.name
    
    @notification = @trigger.append("<div class='notifications'></div>").find("div.notifications")
    
    if $.cookie "dashboard:active:#{@name}"
      @active = true
    else
      @active = false
      
    @setup()
    @bind()
        
  setup: =>
    if @active
      @show(0)
    else
      @hide(0)
      
    unless $.cookie "dashboard:notifications:#{@name}" == null
      @notifications = $.cookie "dashboard:notifications:#{@name}"
    else
      @notifications = 0
    
    @trigger.bind "click", =>
      $.event.trigger 'toggle.sidebar', @
      
  bind: =>
    @trigger.bind "toggle.sidebar", (e,obj) =>
      if obj == @
        @toggle()
      else
        if @active
          @hide()
      
  toggle: =>
    if @active
      @hide(350)
    else
      @show(350)
      
  show: (speed) ->
    $.cookie "dashboard:active:#{@name}", true, 
      expires: 365
      path: "/"
      
    @frame.css
      right: -320
    .delay(speed).show().animate
      right: 0
    , speed
      
    @trigger.addClass('active')
    @active = true
    @clearNotifications()
    
    
  hide: (speed) ->
    $.cookie "dashboard:active:#{@name}", null
      expires: 365
      path: "/"
      
    @frame.css
      right: 0
    .animate(
      right: -320
    , speed
    )
    
    @trigger.removeClass('active')
    @active = false
    
  clearNotifications: =>
    $.cookie "dashboard:notifications:#{@name}", 0, 
      expires: 365
      path: "/"
    @notifications = 0
    @notification.html("")
    @notification.hide()
    
  addNotification: =>
    unless @active
      @notifications += 1
      $.cookie "dashboard:notifications:#{@name}", @notifications, 
        expires: 365
        path: "/"
      @notification.html(@notifications)
      @notification.show()

class Chat extends Sidebar
  
  constructor: (args) ->
    super args
    
    @chat_container = @frame.find(args.chat_container)
    @chat_input = @frame.find(args.chat_input)
    @chat_form = @frame.find(args.chat_form)
    
    @seeded = false
    if $.cookie "dashboard:active:#{@name}"
      @preSeed()
    
    @faye = new Faye.Client("<%= Cloudsdale.config['url'] %>:9191/faye")
    
    @faye.subscribe "/chat", (data) =>
      eval data
    
    @chat_form.bind 'ajax:beforeSend', () =>
      @resetInput()
       
    .submit () =>
      @validateInput()
      
  show: (speed) ->
    super speed
    if @chat_container
      unless @seeded
        @preSeed()
        @seeded = true
      @correctWindow(true)
      
  preSeed: =>
    @seeded = true
    @frame.append("<div class='shader' />")
    $.getJSON "/chat/messages", (data) =>
      i = data.length - 1
      $.each data, (key, val) =>
        @chat_container.prepend("<div timestamp='#{val.timestamp}'class='message'><h5 class='sender'>#{val.sender}</h5><p class='content'>#{val.content}</p></div>")
        @correctWindow(true)
        if key == i
          window.setTimeout ( =>
            @correctWindow(true)
          ), 500
      
  isReadingHistory: () ->
    (@chat_container[0].scrollHeight - @chat_container.scrollTop() == @chat_container.outerHeight())

  correctWindow: (readyForCorrection) ->
    if readyForCorrection
      @chat_container.scrollTop(@chat_container[0].scrollHeight)      
      
  addMessage: (timestamp,sender,message) ->
    readyForCorrection = @isReadingHistory()
    @chat_container.append("<div timestamp='#{timestamp}'class='message'><h5 class='sender'>#{sender}</h5><p class='content'>#{message}</p></div>")
    @correctWindow(readyForCorrection)
    
  validateInput: () ->
    if (@chat_input.attr('value').match(/^\s*$/) == null) and (@chat_input.attr('value').length > 0)
      true
    else
      @resetInput()
      false

  resetInput: () ->
    @chat_input.val('')

$ ->
  
  new Chat
    trigger: "#chat_trigger"
    frame: "#chat_frame"
    preseed_path: "/chat/log"
    chat_container: "#chat_container"
    chat_input: "#message"
    chat_form: "#chat_form"
    name: "chat"
    
  new Sidebar
    trigger: "#settings_trigger"
    frame: "#settings_frame"
    name: "settings"
    
  new Sidebar
    trigger: "#notifications_trigger"
    frame: "#notifications_frame"
    name: "notifications"
    
  new Sidebar
    trigger: "#feed_trigger"
    frame: "#feed_frame"
    name: "feed"
    
