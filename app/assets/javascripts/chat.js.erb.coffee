$ ->
  # class Chat
  # 
  #   constructor: (@faye, @frame_id, @chat_form_id, @chat_sidebar_id, @chat_menu_id) ->
  # 
  #     @self = this
  # 
  #     @frame = $(@frame_id)
  #     @form = $(@chat_form_id)
  #     @sidebar = $(@chat_sidebar_id)
  #     @menu = $(@chat_menu_id)
  #     @channel = $('input#channel[type=hidden]')
  #     @input = $('input#message[type=text]')
  #     @rooms = []
  # 
  #     @faye.subscribe "/system", (data) ->
  #       eval data
  # 
  #     @form.bind 'ajax:beforeSend', () =>
  #       @resetInput()
  # 
  #     .submit () =>
  #       @validateInput()
  # 
  #   connect: () ->
  #     $.getJSON '/chat/connect', (data) =>
  #       @joinRoom(data.token,"System",true)
  #     .success ->
  #       return false
  #     .error ->
  #       return false
  # 
  # 
  #   validateInput: () ->
  #     if (@input.attr('value').match(/^\s*$/) == null) and (@input.attr('value').length > 0)
  #       true
  #     else
  #       @resetInput()
  #       false
  # 
  #   resetInput: () ->
  #     @input.val('')
  # 
  #   joinRoom: (token,name,system) ->
  #     room = new Room(@,token,name,system)
  #     room.connect()
  #     room.makeActive()
  #     @rooms.push room
  #     return room
  #     
  #   findRoomByToken: (token) ->
  #     for room in @rooms
  #       if room.token == token
  #         return room
  #       null
  # 
  # class Room
  #   constructor: (@chat,@token,@name,@system) ->
  # 
  #   connect: () ->
  #     @frame = @chat.frame.append("<div class='room_frame' token='#{@token}'><div class='deadzone' /></div>").find("div[token='#{@token}']")
  #     @room_link = @chat.menu.append("<li token='#{@token}'>#{@name}#{unless @system then "<a href='/chat/rooms/#{@token}/disconnect' data-remote='true' class='disconnect'><img src='<%= image_path('icons/remove.png')%>'/></a>" else ''}</li>").find("li[token='#{@token}']")
  #     @online_list = @chat.sidebar.append("<ul class='online_list' token='#{@token}'><lh>Ponies Online:</lh></ul>").find("ul[token='#{@token}']")
  # 
  #     @subscription = @chat.faye.subscribe "/#{@token}", (data) =>
  #       eval data
  # 
  #     $.get "/chat/rooms/#{@token}/connect"
  # 
  #     @room_link.bind 'click', =>
  #       @makeActive()
  #     
  # 
  #   disconnect: () ->
  #     @subscription.cancel()
  #     @frame.remove()
  #     @room_link.remove()
  #     @online_list.remove()
  # 
  #   broadcastPresence: () ->
  #     $.get "/chat/rooms/#{@token}/presence"
  # 
  #   addMessage: (timestamp,timestamp_human,sender,message) ->
  #     readyForCorrection = this.isReadingHistory()
  #     @frame.append("<div timestamp='#{timestamp}'class='message'><div class='sender'>#{sender}</div><div class='content'><p><span class='time'>#{timestamp_human}</span> - #{message}</p></div></div>")
  #     this.correctWindow(readyForCorrection)
  # 
  #   isReadingHistory: () ->
  #     (@frame[0].scrollHeight - @frame.scrollTop() == @frame.outerHeight())
  # 
  #   correctWindow: (readyForCorrection) ->
  #     if readyForCorrection
  #       scroll = @frame[0].scrollHeight - @frame[0].clientHeight
  #       @frame.scrollTop(scroll)
  # 
  #   makeActive: () ->
  #     @chat.frame.find("div.room_frame.active").removeClass('active')
  #     @chat.menu.find("li.active").removeClass('active')
  #     @chat.sidebar.find("ul.online_list").removeClass('active')
  #     @chat.channel.val("#{@token}")
  #     @frame.addClass('active')
  #     @room_link.addClass('active')
  #     @online_list.addClass('active')
  #     @correctWindow(true)
  #   
  #   addPerson: (private_token, display_name) ->
  #     if @online_list.find("li[token=#{private_token}]").length < 1
  #       @online_list.append("<li token=#{private_token}>#{display_name}</li>")
  #       
  #   removePerson: (private_token) ->
  #     @online_list.find("li[token=#{private_token}]").remove()
  # 
  # faye = new Faye.Client("<%= Cloudsdale.config['url'] %>:9191/faye")
  # chat = new Chat faye, "#chat_frame", "form#new_message", "#chat_sidebar", "#chat_menu"
  # chat.connect()
  # 
  # $(window).load () ->
  #   @chat = chat
  #   chat.joinRoom("cloudsdale","cloudsdale")
  #   
  #   
  #   
  # .unload () ->
  #   console.log ""

    