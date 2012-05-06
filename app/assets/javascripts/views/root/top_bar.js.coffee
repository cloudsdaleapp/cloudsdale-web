class Cloudsdale.Views.TopBar extends Backbone.View
  
  template: JST['root/top_bar']
  
  className: 'navbar navbar-fixed-top'
  
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
      