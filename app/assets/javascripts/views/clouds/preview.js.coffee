class Cloudsdale.Views.CloudsPreview extends Backbone.View
  
  template: JST['clouds/preview']
  
  model: 'cloud'
  tagName: 'div'
  className: 'explore-preview'
  
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