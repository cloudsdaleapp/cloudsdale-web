class Cloudsdale.Views.TopBar extends Backbone.View
  
  template: JST['root/top_bar']
  
  className: 'navbar navbar-fixed-top'
  
  events:
    'click a.brand'         : 'goToRootPage'
    'click a.login-trigger' : 'openSessionDialog'
    'click a.cloud-trigger' : 'toggleCloudExpand'
  
  initialize: ->
    @render()
    @bindEvents()
  
  render: ->
    $(@el).html(@template())
    this
  
  bindEvents: ->
    # Do stuff
  
  openSessionDialog: ->
    view = new Cloudsdale.Views.SessionsDialog(state: 'login').el
    if $('.modal-container').length > 0 then $('.modal-container').replaceWith(view) else $('body').append(view)
    false
  
  toggleCloudExpand: ->
    $('body').toggleClass('with-expanded-cloudbar')
    false
    
  goToRootPage: ->
    Backbone.history.navigate("/",true)
    false