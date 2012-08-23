class Cloudsdale.Views.CloudsDropsDialog extends Backbone.View
  
  template: JST['clouds/drops_dialog']
  
  model: 'cloud'
  collection: 'drops'
  
  tagName: 'div'
  className: 'container-inner container-inner-secondary'
  
  events:
    'click a.close[data-dismiss="dialog"]' : "close"
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
    @.$('ul.cloud-drop-list').html('')
    @.$('a.drop-load-more').removeClass('no-more-results')
    resizeBottomWrapper(@.$('.cloud-sidebar-bottom'))
    
  
  bindEvents: ->
    @collection.on 'add', (model,collection) =>
      if collection.first() == model
        @prependDrop(model)
      else
        @appendDrop(model)
    
    @collection.on 'remove', (model,collection) =>
      @removeDrop(model)
      
    @.$('.cloud-sidebar-bottom').on 'scroll', =>
      if $(@el).scrollTop() > (@el.scrollHeight - $(@el).innerHeight() - 250)
        @fetchMore() unless @collection.lastPage() or @currentlyLoading
  
  unbindEvents: ->
    @collection.off('add')
    @collection.unbindEvents()
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
    new Cloudsdale.Views.CloudsDropsListItem(model: model, template: JST['clouds/drops/list_item_big'])
   
  appendDrop: (model) ->
    @.$('ul.cloud-drop-list').append(@generateDropView(model).el)
    
  prependDrop: (model) ->
    @.$('ul.cloud-drop-list').prepend(@generateDropView(model).el)
  
  removeDrop: (model) ->
    @.$("ul.cloud-drop-list > li[data-model-id=#{model.id}]").remove()
  
  renderDefaultCollection: ->
    
    @collection = new Cloudsdale.Collections.Drops [],
      {
        topic: @model
        url: -> "/v1/#{@topic.type}s/#{@topic.id}/drops.json"
        # subscription: -> "#{@topic.type}s:#{@topic.id}:drops"
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
    @.$('.cloud-drops-search-wrapper').removeClass('with-search-results')
    @unbindEvents()
    @renderDefaultCollection()
    false
  
  doSearch: (event) ->
    event.preventDefault()
    @.$('.cloud-drops-search-wrapper').addClass('with-search-results')
    @renderSearchCollection(@.$('input[name=q]').val())
    false
  
  close: ->
    $(@el).parent().removeClass('show-secondary')
    setTimeout =>
      $(@el).remove()
    , 400
    false
    
    
