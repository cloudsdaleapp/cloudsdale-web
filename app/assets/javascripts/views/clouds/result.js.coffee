class Cloudsdale.Views.CloudsResult extends Backbone.View
  
  template: JST['clouds/result']
  
  model: 'cloud'
  tagName: 'li'
  className: 'explore-cloud-list-item'
  
  events:
    'click a[data-action=join-cloud]' : "joinCloud"
  
  initialize: (args) ->
    
    args = {} unless args
        
    @render()
    @bindEvents()
              
  render: ->
    $(@el).html(@template(model: @model))
    this
  
  bindEvents: ->
    # TODO
  
  joinCloud: ->
    Backbone.history.navigate("/clouds/#{@model.id}",true)
    false