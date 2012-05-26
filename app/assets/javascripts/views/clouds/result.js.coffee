class Cloudsdale.Views.CloudsResult extends Backbone.View
  
  template: JST['clouds/result']
  
  model: 'cloud'
  tagName: 'li'
  className: 'explore-result'
  
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