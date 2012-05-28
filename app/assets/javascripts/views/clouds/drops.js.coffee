class Cloudsdale.Views.CloudsDrops extends Backbone.View
  
  template: JST['clouds/drops']
  
  model: 'cloud'
  collection: 'drops'
  
  tagName: 'div'
  className: 'drop-wrapper'
  
  events:
    'click a.drop-load-more' : 'fetchMore'
    'click a.drop-close-search' : 'cancelSearch'
    'submit form' : 'doSearch'
  
  initialize: (args) ->
    
    @currentlyLoading = false
    @render()
    @renderDefaultCollection()
    
  render: ->
    $(@el).html(@template(collection: @collection, model: @model))
    this
  
  refreshGfx: ->
    @.$('ul.drop-list').html('')
    @.$('a.drop-load-more').removeClass('no-more-results')
    
  
  bindEvents: ->
    @collection.on 'add', (model,collection) =>
      if collection.first() == model
        @prependDrop(model)
      else
        @appendDrop(model)
    
    $(@el).on 'scroll', =>
      if $(window).scrollTop() > $(document).height() - $(window).height() - 100
        @fetchMore() unless @collection.lastPage() or @currentlyLoading
  
  unbindEvents: ->
    @collection.off('add')
    $(@el).off('scroll')
    
  fetchMore: ->
    @.$('a.drop-load-more').text('loading more...').attr('disabled','disabled')
    @currentlyLoading = true
    @collection.fetchMore
      success: =>
        @currentlyLoading = false
        @.$('a.drop-load-more').text('load more...').attr('disabled',null)
        @.$('a.drop-load-more').addClass('no-more-results') if @collection.lastPage()
  
  generateDropView: (model) ->
    new Cloudsdale.Views.CloudsDropsListItem(model: model)
   
  appendDrop: (model) ->
    @.$('ul.drop-list').append(@generateDropView(model).el)
    
  prependDrop: (model) ->
    @.$('ul.drop-list').prepend(@generateDropView(model).el)
  
  renderDefaultCollection: ->
    
    @collection = new Cloudsdale.Collections.Drops [],
      {
        topic: @model
        url: -> "/v1/#{@topic.type}s/#{@topic.id}/drops.json"
        subscription: -> "#{@topic.type}s:#{@topic.id}:drops"
      }
    
    @refreshGfx()
    @bindEvents()
    
    @fetchMore()
  
  renderSearchCollection: (query) ->
    
    query = "" unless query
    
    @collection = new Cloudsdale.Collections.Drops [],
      {
        topic: @model
        url: -> "/v1/#{@topic.type}s/#{@topic.id}/drops/search.json?q=#{query}"
      }
    
    @refreshGfx()
    @bindEvents()
    
    @fetchMore()
  
  cancelSearch: ->
    @.$('input[name=q]').val('')
    $(@el).removeClass('with-search-results')
    @unbindEvents()
    @renderDefaultCollection()
  
  doSearch: (event) ->
    event.preventDefault()
    $(@el).addClass('with-search-results')
    @renderSearchCollection(@.$('input[name=q]').val())
    false
    
    
