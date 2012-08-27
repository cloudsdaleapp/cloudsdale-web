class Cloudsdale.Views.CloudsUserDialog extends Backbone.View
  
  template: JST['clouds/user_dialog']
  
  model: 'user'
  tagName: 'div'
  className: 'container-inner container-inner-secondary'

  events:
    'click a.close[data-dismiss="dialog"]' : "close"
    'click a[data-action="ban"]' : 'toggleUserBan'
  
  initialize: (args) ->
    
    @render()
    @bindEvents()
    
    this
  
  render: ->
    $(@el).html(@template(model: @model))
    
    resizeBottomWrapper(@.$('.cloud-sidebar-bottom'))
    
    this
  
  bindEvents: ->
    @model.on 'change', (event,user) =>
      @render()
          
  close: ->
    $(@el).parent().removeClass('show-secondary')
    setTimeout =>
      $(@el).remove()
    , 400
    false
  
  toggleUserBan: ->
    
    @.$('a[data-action="ban"]').attr('disabled','disabled')
    
    if @model.get('is_banned')
      @model.unban
        success: (user) =>
          @model.set(user)
          
    else
      @model.ban
        success: (user) =>
          @model.set(user)