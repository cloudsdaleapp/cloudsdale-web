class Cloudsdale.Views.Root extends Backbone.View
 
  template: JST['root']
  
  tagName: 'body'
    
  initialize: ->
    @render()
    
    @topBarView = new Cloudsdale.Views.TopBar()
    @.$(".navbar.navbar-fixed-top").replaceWith(@topBarView.el)
    
    @bindEvents()
    
    session.get('clouds').each (cloud) =>
      session.listenToCloud(cloud)
      view = new Cloudsdale.Views.CloudsToggle(model: cloud)
      $('.cloudbar > .cloud-list').append(view.el)
  
  render: ->
    $(@el).html(@template())
    this
    
  bindEvents: ->
    $(@el).bind 'page:show', (event,page_id) =>
      @show(page_id) if page_id == "root"
    
    @.$(".cloud-list").mousewheel (event, delta) ->
      @scrollTop -= (delta * 30)
      event.preventDefault()
    
    @.$('.modal-container').append(new Cloudsdale.Views.SessionsDialog().el)
    
  show: (id) ->
    @.$('.view-container').removeClass('active')
    @.$(".view-container[data-page-id=#{id}]").addClass('active')