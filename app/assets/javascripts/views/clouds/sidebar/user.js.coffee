class Cloudsdale.Views.CloudsSidebarUser extends Backbone.View

  template: JST['clouds/sidebar/user']

  model: 'ban'
  tagName: 'li'
  className: 'sidebar-item'

  initialize: (args,options) ->
    @render()
    @bindEvents()
    @refreshGfx()

  render: ->
    $(@el).html(@template(view: @, model: @model))
    @.$('a').attr('data-entity-id',@model.id).attr('data-action',"showUser")
    this

  refreshGfx: ->
    $(@el).removeClass('status-offline').removeClass('status-online')
    $(@el).addClass("status-#{@model.get('status')}").attr('data-status',@model.numericStatus())

  bindEvents: ->
    @model.on 'change', =>
      @render()
      @refreshGfx()
