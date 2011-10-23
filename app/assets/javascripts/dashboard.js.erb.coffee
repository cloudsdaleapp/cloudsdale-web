class Sidebar

  constructor: (args) ->
    @frame = $(args.frame)
    @trigger = $(args.trigger)
    @faye = args.faye_client
    @name = args.name
    @preseed_path = args.preseed_path
    @seeded = false
    
    @notification = @trigger.append("<div class='notifications'></div>").find("div.notifications")
      
    unless $.cookie "dashboard:notifications:#{@name}" == null
      @setNotifications(parseInt($.cookie "dashboard:notifications:#{@name}"))
    else
      @setNotifications(0)
    
    if $.cookie "dashboard:active:#{@name}"
      @active = true
    else
      @active = false
      @hide(0)
        
  setup: =>
    if @active
      @show(0)
    else
      @hide(0)
      
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
    @clearNotifications()
    
    unless @seeded
      @preSeed(@preseed_path)
    
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
    
    
  hide: (speed) =>
    $.cookie "dashboard:active:#{@name}", null
      expires: 365
      path: "/"
      
    @frame.css
      right: 0
    .animate(
      right: -320
    , speed, =>
      @frame.hide()
    )
    
    @trigger.removeClass('active')
    @active = false

  preSeed: (path) ->
    @seeded = true
    
  clearNotifications: =>
    $.cookie "dashboard:notifications:#{@name}", 0, 
      expires: 365
      path: "/"
    @notifications = 0
    @notification.html("")
    @notification.hide()
    
  addNotification: (message) =>
    unless @active
      @notifications += 1
      $.cookie "dashboard:notifications:#{@name}", @notifications, 
        expires: 365
        path: "/"
      @notification.html(@notifications)
      @notification.show()
      
    $.titleAlert "#{message}",
      requireBlur: true
      stopOnFocus: true
      duration: 0
      interval: 1000
      
  setNotifications: (amount) =>
    @notifications = amount
    if @notifications > 0
      @notification.html(@notifications)
      @notification.show()
    else
      @notification.hide()
      
class Chat extends Sidebar
  
  constructor: (args) ->
    super args
    
    @chat_container = @frame.find(args.chat_container)
    @chat_input = @frame.find(args.chat_input)
    @chat_form = @frame.find(args.chat_form)
    
    @faye = new Faye.Client("<%= Cloudsdale.config['url'] %>:9191/faye")
    @faye.subscribe "/chat", (data) =>
      eval data
      
    @setup()
    @bind()
      
  show: (speed) ->
    super speed
    if @chat_container
      @correctWindow(true)
      
  bind: =>
    super
    
    @chat_input.BetterGrow
      initial_height: 12
      do_not_enter: null
      
    .keydown (e) =>
      @resizeElements()
      if e.which == 13 and e.shiftKey == false
        @chat_form.submit()
        return false
    
    @chat_form.bind 'ajax:beforeSend', () =>
      @resetInput()
       
    .submit () =>
      @validateInput()
      
  preSeed: (path) =>
    super path
    if @chat_container
      $.getJSON path, (data) =>
        i = data.length - 1
        $.each data, (key, val) =>
          t = new Date(Date._parse(val.timestamp))
          @chat_container.prepend(
            "<div timestamp='#{val.timestamp}'class='message'>
            <h5 class='sender'><a href='#{val.user_path}'>#{val.sender}</a><span class='time'>#{t.toString('HH:mm:ss')}</span></h5>
            <p class='content'>#{val.content}</p></div>")
          @correctWindow(true)
          if key == i
            window.setTimeout ( =>
              @correctWindow(true)
            ), 500
  
  resizeElements: () ->
    window.setTimeout ( =>
      s = @chat_input.outerHeight() - 2
      @chat_container.css
        bottom: s
      @correctWindow(true)
    ), 110
    
      
  isReadingHistory: () ->
    (@chat_container[0].scrollHeight - @chat_container.scrollTop() == @chat_container.outerHeight())

  correctWindow: (readyForCorrection) ->
    if readyForCorrection
      @chat_container.scrollTop(@chat_container[0].scrollHeight)      
      
  addMessage: (timestamp,sender,content,user_path) ->
    readyForCorrection = @isReadingHistory()
    t = new Date(Date._parse(timestamp))
    @chat_container.append(
      "<div timestamp='#{timestamp}'class='message'>
      <h5 class='sender'><a href='#{user_path}'>#{sender}</a><span class='time'>#{t.toString('HH:mm:ss')}</span></h5>
      <p class='content'>#{content}</p></div>")
    @correctWindow(readyForCorrection)
    @addNotification()
    
  validateInput: () ->
    if (@chat_input.attr('value').match(/^\s*$/) == null) and (@chat_input.val.length > 0)
      true
    else
      false

  resetInput: () ->
    @chat_input.val('')
    
  addNotification: () =>
    message = "NEW MESSAGE"
    super message
      
class Notifications extends Sidebar

  constructor: (args) ->
    super args
    @setup()
    @bind()

  preSeed: (path) =>
    $.get path, (data) =>
      @frame.html(data)
      
class Friends extends Sidebar

  constructor: (args) ->
    super args
    
    @setup()
    @bind()

  preSeed: (path) =>
    $.get path, (data) =>
      @frame.html(data)
      @refresh_trigger = @frame.find("a#freinds_refresh_trigger")
      @refresh_trigger.bind 'click', =>
        @preSeed(@preseed_path)

$ ->

  new Chat
    trigger: "#chat_trigger"
    frame: "#chat_frame"
    preseed_path: "/chat/messages"
    chat_container: "#chat_container"
    chat_input: "#message"
    chat_form: "#chat_form"
    name: "chat"
    
  new Notifications
    trigger: "#notifications_trigger"
    frame: "#notifications_frame"
    preseed_path: "/notifications"
    name: "notifications"
    
  new Friends
    trigger: "#friends_trigger"
    frame: "#friends_frame"
    name: "friends"
    preseed_path: "/sessions"
    
