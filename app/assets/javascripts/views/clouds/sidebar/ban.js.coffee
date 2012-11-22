class Cloudsdale.Views.CloudsSidebarBan extends Backbone.View

  template: JST['clouds/sidebar/ban']

  model: 'ban'
  tagName: 'div'
  className: 'sidebar-block sidebar-input'

  events:
    'click [data-action=ban-revoke]' : "revokeBan"

  initialize: (args,options) ->
    @render()
    @bindEvents()

  render: ->
    $(@el).html(@template(view: @, model: @model))
    this

  bindEvents: ->
    @model.on 'change', => @render()

  revokeBan: ->
    @model.save { revoke: true }
    false
