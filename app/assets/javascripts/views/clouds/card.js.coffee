class Cloudsdale.Views.CloudsPreview extends Backbone.View
  
  template: JST['clouds/card']
  
  model: 'cloud'
  tagName: 'li'
  className: 'explore-card'
  
  events:
    'click a[data-action=join-cloud]' : "joinCloud"
  
  initialize: (args) ->
    
    args = {} unless args
    
    @model = args.model if args.model
    
    @render()
    @bindEvents()
          
  render: ->
    $(@el).html(@template(view: @, model: @model))
    this
  
  bindEvents: ->
    # TODO
  
  joinCloud: ->
    Backbone.history.navigate("/clouds/#{@model.id}",true)
    false