class Cloudsdale.Views.CloudsDropsListItem extends Backbone.View

  template: JST['clouds/drops/list_item']

  model: 'drop'
  tagName: 'li'
  className: 'drop'

  events:
    'click a.drop-title'      : 'visit'
    'click a.drop-preview'    : 'visit'
    'click a.drop-big-title'  : 'visit'
    'click a.drop-big-preview': 'visit'
    'click a.drop-vote-up'    : 'voteUp'
    'click a.drop-vote-down'  : 'voteDown'

  initialize: (args) ->

    args ||= {}

    @template = args.template if args.template

    @render()

    @bindEvents()
    @refreshGfx()

  render: ->
    $(@el).html(@template(model: @model)).attr('data-model-id',@model.id)
    this

  refreshGfx: ->
    @.$('a.drop-big-title span').text(@model.get('title')).truncate({rows: 4})

  bindEvents: ->
    $(window).bind 'resizestop', => @refreshGfx()

  visit: (event) ->
    event.preventDefault()
    # @model.visit()

    _href = @model.get('url').match /([a-z]{1,6}\:\/\/)([a-z0-9\.\,\-\_\:]*)(\/?[a-z0-9\!\'\"\.\,\-\_\/\?\:\&\=\#\%\+\(\)]*)/i

    protocol = _href[1]
    top_dom = _href[2]
    path = _href[3]

    inhouse = (top_dom.match(/www\.cloudsdale\.org/i) != null)

    if inhouse
      event.preventDefault()
      Backbone.history.navigate(path,true)
    else
      window.open(@model.get('url'),'_blank')

    false

  voteUp: ->
    @render()
    false

  voteDown: ->
    @render()
    false
