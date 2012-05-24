class Cloudsdale.Views.RootTncDialog extends Backbone.View
  
  template: JST['root/tnc_dialog']
  
  tagName: 'div'
  className: 'modal-container'
    
  events:
    'click a.accept_tnc' : 'acceptTnc'
  
  initialize: (args) ->
    args = {} unless args
        
    @render()
    @bindEvents()
    
    this
  
  render: ->
    $(@el).html(@template(user: session.get('user')))
    this
    
  bindEvents: ->
    
    @.$('.modal').modal().bind 'hide', =>
      @.$('.input-group').tooltip('hide')
      window.setTimeout ->
        $(@el).remove()
      , 500
    
    @.$(':file').change => @submitAvatar()
  
  acceptTnc: ->
    session.get('user').acceptTnc
      success: (user,response) =>
        @.$('.modal').modal('hide')
        
    false