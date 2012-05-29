class Cloudsdale.Views.CloudsDropsListItem extends Backbone.View
  
  template: JST['clouds/drops/list_item']
  
  model: 'drop'
  tagName: 'li'
  className: 'drop'
    
  events:
    'click a.drop-title'      : 'visit'
    'click a.drop-preview'    : 'visit'
    'click a.drop-vote-up'    : 'voteUp'
    'click a.drop-vote-down'  : 'voteDown'
    
  initialize: (args) ->
    
    @render()
  
  render: ->
    $(@el).html(@template(model: @model)).attr('data-model-id',@model.id)
    this
    
  visit: (event) ->
    event.preventDefault()
    @model.visit()
    window.open(@model.get('url'),'_blank')
    false
  
  voteUp: ->
    @render()
    false
  
  voteDown: ->
    @render()
    false