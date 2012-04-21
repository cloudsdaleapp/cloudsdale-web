class Cloudsdale.Views.CloudsToggle extends Backbone.View
 
  template: JST['clouds/toggle']
  
  model: 'cloud'
  tagName: 'li'
  className: 'cloud-toggle'
  
  events: {
    'click a' : 'activate'
  }
  
  initialize: ->
    @render()
    @bind()
  
  render: ->
    $(@el).html(@template(model: @model))
    this
  
  bind: ->
    $(@el).bind 'page:show', (event,page_id) =>
      if page_id == @model.id
        $(@el).addClass('active') 
      else
        $(@el).removeClass('active') 
    
    nfc.on "#{@model.type}:#{@model.id}:chat", (payload) ->
      console.log payload
      
  activate: ->
    Backbone.history.navigate("/clouds/#{@model.id}",true)
    false