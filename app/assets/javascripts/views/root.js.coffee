class Cloudsdale.Views.Root extends Backbone.View
 
  template: JST['root']
  
  tagName: 'body'
    
  initialize: ->
    @render()
    
    @topBarView = new Cloudsdale.Views.TopBar()
    @.$(".navbar.navbar-fixed-top").replaceWith(@topBarView.el)
    
    @bindEvents()
    
    @refreshGfx()
    
    @getTweets()
    
    if session.isLoggedIn()
      @renderSessionClouds()
            
      if session.get('user').get('needs_to_confirm_registration')
        @openSessionDialog('complete')
    
    rootSessionView = new Cloudsdale.Views.RootSession
    @.$('.root-get-started-inner').html(rootSessionView.el)
        
  render: ->
    $(@el).html(@template())
    this
    
  bindEvents: ->
    $(@el).bind 'clouds:join', (event,cloud) =>
      @renderCloud(cloud)
    
    $(@el).bind 'clouds:initialize', =>
      @renderSessionClouds()
    
    $(@el).bind 'page:show', (event,page_id) =>
      @show(page_id) if page_id == "root"
    
    $(@el).bind 'notifications:add', (event,args) =>
      @addNotification(args)
      
    $(@el).bind 'notifications:remove', (event,args) =>
      @removeNotification(args)
    
    $(@el).bind 'notifications:clear', (event,args) =>
      @clearNotifications(args)
    
    @.$(".cloud-list").mousewheel (event, delta) ->
      @scrollTop -= (delta * 30)
      event.preventDefault()
    .sortable
      axis: 'y'
      stop: (event, ui) =>
        @refreshListPositions()
        
    $(document).bind 'click', (event) ->
      $("body").removeClass('with-expanded-cloudbar')
      
    session.get('user').bind 'change', (user) =>
      @refreshGfx()
    
    $(document).bind 'keydown', (e) =>
                      
      activeToggle = @.$('.cloud-toggle.active')
      
      if ((e.keyCode == 38) or (e.keyCode == 40)) and e.shiftKey
        
        if e.keyCode == 40
          next = activeToggle.next()
          if next.length > 0
            id = next.attr('data-cloud-id')
            Backbone.history.navigate("/clouds/#{id}",true)
        
        if e.keyCode == 38
          prev = activeToggle.prev()
          if prev.length > 0
            id = prev.attr('data-cloud-id')
            Backbone.history.navigate("/clouds/#{id}",true)
            
  refreshGfx: ->
    if session.isLoggedIn()
      $(@el).addClass('with-active-session')
    else
      $(@el).removeClass('with-active-session')
  
  refreshListPositions: ->
    @.$(".cloud-list > li").each (index,elem) =>
      _pos = @.$(elem).prevAll().length
      $.cookie "cloud:#{@.$(elem).attr('data-cloud-id')}:toggle:pos", _pos,
        expires: 365
        path: "/"
  
  reorderClouds: ->
    _elements = @.$(".cloud-list > li")
    _elements.sort (a,b) ->
      posA = $.cookie("cloud:#{$(a).attr('data-cloud-id')}:toggle:pos")
      posB = $.cookie("cloud:#{$(b).attr('data-cloud-id')}:toggle:pos")
      compA = if typeof posA == 'string' then parseInt(posA) else 1000
      compB = if typeof posB == 'string' then parseInt(posB) else 1000
      return (if (compA < compB) then -1 else (if (compA > compB) then 1 else 0))
      
    @.$(".cloud-list").append(_elements)
    
  show: (id) ->
    @.$('.view-container').removeClass('active')
    @.$(".view-container[data-page-id=#{id}]").addClass('active')
  
  moveToggleFirst: (cloud) ->
    toggle = @.$("li.cloud-toggle[data-cloud-id=#{cloud.id}]")
    @.$('.cloudbar > ul.cloud-list').prepend(toggle)
    
  
  openSessionDialog: (state) ->
    
    window.setTimeout =>
      view = new Cloudsdale.Views.SessionsDialog(state: state).el
      if @.$('.modal-container').length > 0 then @.$('.modal-container').replaceWith(view) else $(@el).append(view)
    , 100
  
  renderSessionClouds: ->
    session.get('clouds').each (cloud) =>
      @renderCloud(cloud)
      
    @reorderClouds()
    @refreshListPositions()
    
  renderCloud: (cloud) ->
            
    if @.$(".cloudbar > .cloud-list > li[data-cloud-id=#{cloud.id}]").length == 0
      view = new Cloudsdale.Views.CloudsToggle(model: cloud)
      @.$('.cloudbar > .cloud-list').append(view.el)
      cloud.announcePresence()
  addNotification: (args) ->
    if @.$('.main-container > ul.notifications').length <= 0
      @.$('.main-container').append("<ul class='notifications'/>")
        
    view = new Cloudsdale.Views.RootNotification(args)
    @.$('ul.notifications').append(view.el)
    
    this
  
  removeNotification: (args) ->
    @.$('.main-container > ul.notifications').remove() if @.$('.main-container > ul.notifications > li').length <= 0
  
  clearNotifications: (args) ->
    this
  
  getTweets: ->
    $.ajax
      type: 'GET'
      url: "https://api.twitter.com/statuses/user_timeline.json"
      data: { screen_name: "Cloudsdale_org" }
      dataType: 'jsonp'
      crossDomain: true
        
      success: (tweets) =>
        $.each tweets, (id,tweet) =>
          
          tweetsWrapper = @.$('.root-tweets').removeClass('loading-tweets')
          
          tweetsWrapper.find('.carousel > .carousel-inner').append(
            "<div class='root-tweet item #{if id == 0 then "active" else ""}' >
              #{"<span class='root-tweet-sender'>@" + tweet.user.screen_name + ":</span>" + "<p class='root-tweet-content'>#{twttr.txt.autoLink(twttr.txt.htmlEscape(tweet.text))}</p>" }
            </div>"
          )
          
          tweetsWrapper.find('.carousel').carousel(
            interval: 7000
          )
          
      error: (response) =>
        # resp = $.parseJSON(response.responseText)
        # @.$('.input-group').tooltip(
        #   placement: 'top'
        #   trigger: 'manual'
        #   animation: false
        #   title: "Something went wrong... try again later."
        # ).tooltip('show')
        