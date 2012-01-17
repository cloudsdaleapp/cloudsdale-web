do ($ = jQuery) ->
  
  class CloudExtras
    constructor: (@frame,args) ->
      
      @cloud = args.cloud
      # Setup elements
      @expandTrigger = @frame.find('a.expand-trigger')
      @usersList = @frame.find('ul.cloud-users-list')
      @faye = if args.faye then args.faye else @cloud.faye
      
      @bind()
    
    bind: =>
      @expandTrigger.bind 'click', =>
        @frame.toggleClass('expanded')
        if @frame.hasClass('expanded') then @expandTrigger.find('span').text("less") else @expandTrigger.find('span').text("more")
      
      @faye.subscribe "/cloud/#{@cloud.cloudId}/presence", (data) =>
        @userRefresh(data.users) if data.status == 'join'
        @userPurge(data) if data.status == 'leave'
    
    userRefresh: (users) =>
      $.each(users, (index,d) =>
        userInList = @usersList.find("li.#{d.user_id}")
        if userInList[0] == undefined
          if image_src != null
            image_src = d.user_avatar
          else
            image_src = ""
            
          newItem = @usersList.append("<li class='#{d.user_id}'>
            <a rel='twipsy' data-original-title='#{d.user_name}' data-placement='left' data-offset='-2' href='#{d.user_path}'>
              <img src='#{image_src}' alt='#{d.user_name}' />
            </a>
          </li>").find("li.#{d.user_id}")
          newItem.find('a').twipsy()
        else
          userInList.removeClass('dropped')
      )
    
    userPurge: (data) =>
      userInList = @usersList.find("li.#{data.user_id}")
      userInList.addClass('dropped')
      window.setTimeout ( =>
        @usersList.find("li.#{data.user_id}.dropped").remove()
      ), 10000
      
  $.fn.cloudExtras = ->
    new CloudExtras(@,arguments[0])