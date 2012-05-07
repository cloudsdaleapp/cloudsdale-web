class Cloudsdale.Views.TopBar extends Backbone.View
  
  template: JST['root/top_bar']
  
  className: 'navbar navbar-fixed-top'
  
  events:
    'click a.login-trigger' : 'openSessionDialog'
  
  initialize: ->
    @render()
    @bindEvents()
  
  render: ->
    $(@el).html(@template())
    this
  
  bindEvents: ->
    @.$('a.brand').bind 'click', ->
      Backbone.history.navigate("/",true)
      false
    
    @.$('a.cloud-trigger').bind 'click', ->
      $('body').toggleClass('with-expanded-cloudbar')
      false
  
  openSessionDialog: ->
    view = new Cloudsdale.Views.SessionsDialog().el
    if $('.modal-container').length > 0 then $('.modal-container').replaceWith(view) else $('body').append(view)
    false