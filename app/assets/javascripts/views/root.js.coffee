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
    $(@el).bind 'clouds:join', (cloud) =>
      @renderCloud(cloud)
    
    $(@el).bind 'clouds:initialize', =>
      @renderSessionClouds()
    
    $(@el).bind 'page:show', (event,page_id) =>
      @show(page_id) if page_id == "root"
    
    @.$(".cloud-list").mousewheel (event, delta) ->
      @scrollTop -= (delta * 30)
      event.preventDefault()
    
    session.get('user').bind 'change', (user) =>
      @refreshGfx()
  
  refreshGfx: ->
    if session.isLoggedIn()
      $(@el).addClass('with-active-session')
    else
      $(@el).removeClass('with-active-session')
    
  show: (id) ->
    @.$('.view-container').removeClass('active')
    @.$(".view-container[data-page-id=#{id}]").addClass('active')
  
  openSessionDialog: (state) ->
    # view = new Cloudsdale.Views.SessionsDialog(state: state).el
    # if @.$('.modal-container').length > 0 then @.$('.modal-container').replaceWith(view) else $(@el).append(view)
    
    window.setTimeout =>
      view = new Cloudsdale.Views.SessionsDialog(state: state).el
      if @.$('.modal-container').length > 0 then @.$('.modal-container').replaceWith(view) else $(@el).append(view)
    , 100
  
  renderSessionClouds: ->
    session.get('clouds').each (cloud) =>
      @renderCloud(cloud)
      
  renderCloud: (cloud) ->
    session.listenToCloud(cloud)
    view = new Cloudsdale.Views.CloudsToggle(model: cloud)
    @.$('.cloudbar > .cloud-list').append(view.el)
  
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
        