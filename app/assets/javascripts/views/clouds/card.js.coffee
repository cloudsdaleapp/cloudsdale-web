class Cloudsdale.Views.CloudsCard extends Backbone.View

  template: JST['clouds/card']

  model: 'cloud'
  tagName: 'li'
  className: 'span1'

  events:
    'click a[data-action=join-cloud]' : "joinCloud"

  initialize: (args) ->

    args = {} unless args

    @model = args.model if args.model

    @render()
    @bindEvents()
    setTimeout =>
      @refreshGfx()
    , 10

  render: ->
    $(@el).html(@template(view: @, model: @model))
    @model.on 'change', => @refreshGfx()

    this

  refreshGfx: ->
    @.$('.explore-cloud-list-image').css('background-image',"url(#{@model.get('avatar').normal})")
    @.$('.explore-cloud-list-title').text(@model.get('name')).truncate({rows: 2})
    # @.$('.explore-cloud-list-description').text(@model.get('description')).truncate({rows: 3})

  bindEvents: ->
    @model.on 'change', => @refreshGfx()
    # $(window).bind 'resizestop', => @refreshGfx()

  joinCloud: (event) ->
    event.preventDefault()
    Backbone.history.navigate(@model.link(),true)
    false
