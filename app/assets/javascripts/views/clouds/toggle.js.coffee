class Cloudsdale.Views.CloudsToggle extends Backbone.View
 
  template: JST['clouds/toggle']
  
  model: 'cloud'
  tagName: 'li'
  className: 'cloud-toggle'
  
  events: {
    'click' : 'toggle'
  }
  
  initialize: ->
    @render()
    @bind()
  
  render: ->
    $(@el).html(@template(model: @model))
    this
  
  bind: ->
    $(@el).bind 'clouds:show', (event,cloud_id) =>
      $(@el).addClass('active') if cloud_id == @model.id
    
    # nfc.on "#{@model.type}:#{@model.id}:chat", (payload) ->
    #   console.log payload
      
  toggle: ->
    $('.cloud-toggle').removeClass('active')
    $(@el).addClass('active')
    Backbone.history.navigate("/clouds/#{@model.id}",true)
    false
    
    # console.log Backbone.Router()
    # if @model.active then  else 
      