class Cloudsdale.Views.ExploreSearch extends Backbone.View

  template: JST['explore/search']
  className: 'explore-search-wrapper'

  events:
    'submit form#explore-search' : 'doSearch'
    'click a.drop-close-search' : 'cancelSearch'

  initialize: (args) ->

    args = {} unless args

    @collection = new Cloudsdale.Collections.Clouds()

    @render()

  render: ->
    $(@el).html(@template(collection: @collection))
    this

  bindEvents: ->
    @collection.on 'add', (model,collection) =>
      view = new Cloudsdale.Views.CloudsResult(model: model)
      @.$('ul.explore-cloud-list').append(view.el)

  unbindEvents: ->
    @collection.off('add')

  doSearch: (event) ->

    @clearPreviousSearch()

    @unbindEvents()

    query = @.$("form#explore-search > input[name=q]").val()

    @collection = new Cloudsdale.Collections.Clouds [],
      url: -> "/v1/clouds/search.json?q=#{query}"

    @bindEvents()

    @collection.fetchMore
      success: =>
        $(@el).addClass('with-search-results')

    event.preventDefault()
    false

  clearPreviousSearch: ->
    $(@el).removeClass('with-search-results')
    @.$('ul.explore-cloud-list').html('')
    false

  cancelSearch: ->
    @clearPreviousSearch()
    @.$("form#explore-search > input[name=q]").val('')
    $(@el).removeClass('with-search-results')
    false
