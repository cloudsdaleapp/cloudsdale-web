class Cloudsdale.Views.Root extends Backbone.View
 
  template: JST['root']
  
  tagName: 'body'
    
  initialize: ->
    @render()
    
    @topBarView = new Cloudsdale.Views.TopBar()
    @.$(".navbar.navbar-fixed-top").replaceWith(@topBarView.el)
    
    @bindEvents()
    
    @refreshGfx()
    
    @renderSessionClouds() if session.isLoggedIn()
  
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
  
  renderSessionClouds: ->
    session.get('clouds').each (cloud) =>
      @renderCloud(cloud)
      
  renderCloud: (cloud) ->
    session.listenToCloud(cloud)
    view = new Cloudsdale.Views.CloudsToggle(model: cloud)
    @.$('.cloudbar > .cloud-list').append(view.el)