class Cloudsdale.Views.UsersSettingsDialog extends Backbone.View
  
  template: JST['users/settings_dialog']
  
  tagName: 'div'
  className: 'modal-container'
  
  initialize: (args) ->
    args = {} unless args
    
    @render()
    @bindEvents()
  
  render: ->
    $(@el).html(@template(session: window.session, user: window.session.get('user')))
    this

  bindEvents: ->
    @.$('.modal').modal().bind 'hide', =>
      @.$('.input-group').tooltip('hide')
      window.setTimeout ->
        $(@el).remove()
      , 500