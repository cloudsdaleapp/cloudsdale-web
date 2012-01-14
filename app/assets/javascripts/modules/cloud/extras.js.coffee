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
        @userJoin(data.user_id,data.data) if data.status == 'join'
        @userLeave(data.user_id) if data.status == 'leave'
    
    userJoin: (uid,data) ->
      if @usersList.find("li.#{uid}").length < 1
        image_src = data.avatar
        newItem = @usersList.append("<li class='#{uid}'>
          <a rel='twipsy' data-original-title='#{data.name}' data-placement='left' data-offset='-2' href='#{data.path}'>
            <img src='#{image_src}' alt='#{data.name}' />
          </a>
        </li>").find("li.#{uid}")
        newItem.find('a').twipsy()
    
    userLeave: (uid) ->
      @usersList.find("li.#{uid}").remove()
      
  $.fn.cloudExtras = ->
    new CloudExtras(@,arguments[0])