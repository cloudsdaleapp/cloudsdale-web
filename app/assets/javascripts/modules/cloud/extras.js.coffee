do ($ = jQuery) ->
  
  class CloudExtras
    constructor: (@frame,args) ->
      
      @cloud = args.cloud
      # Setup elements
      @expandTrigger = @frame.find('a.expand-trigger')
      @usersList = @frame.find('ul.cloud-users-list')
      
      @bind()
      @announcePresence()
      @userPurge()
    
    bind: =>
      @expandTrigger.bind 'click', =>
        @frame.toggleClass('expanded')
        if @frame.hasClass('expanded') then @expandTrigger.find('span').text("less") else @expandTrigger.find('span').text("more")
      
      @subscription = document.fayeCli.subscribe "/cloud/#{@cloud.cloudId}/presence", (data) =>
        @refreshPresence(data)
      
    
    refreshPresence: (user) =>
      userInList = @usersList.find("li.#{user.id}")
      timestamp = new Date().getTime()
      if userInList[0] == undefined
        if image_src != null
          image_src = if user.avatar then user.avatar else $('.preload.avatar-user-chat').css('background-image').replace(/url\(|\)|"|'/g,"")
        else
          image_src = ""
        
        newItem = @usersList.append("<li class='#{user.id}' data-last-seen= '#{timestamp}'>
          <a rel='twipsy' data-original-title='#{user.name}' data-placement='left' data-offset='-2' href='#{user.path}'>
            <img src='#{image_src}' alt='#{user.name}' />
          </a>
        </li>").find("li.#{user.id}")
        newItem.find('a').twipsy()
      else
        userInList.attr('data-last-seen',timestamp)
    
    userPurge: () =>
      window.setTimeout ( =>
        inactiveUsers = @usersList.find("li").filter ->
          $(@).attr('data-last-seen') < new Date().getTime() - 35000
        inactiveUsers.remove()
        window.setTimeout ( =>
          @userPurge()
        ), 25000
      ), 5000
    
    announcePresence: (initial) ->
      window.setTimeout ( =>
        document.fayeCli.publish "/cloud/#{@cloud.cloudId}/presence", @cloud.parent.userData
        window.setTimeout ( =>
          @announcePresence()
        ), 27000
      ), 3000
      
      
  $.fn.cloudExtras = ->
    new CloudExtras(@,arguments[0])