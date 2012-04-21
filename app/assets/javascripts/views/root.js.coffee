class Cloudsdale.Views.Root extends Backbone.View
 
  template: JST['root']
  
  tagName: 'div'
  className: 'main-container'
    
  initialize: ->
    @render()
    @bind()
  
  render: ->
    $(@el).html(@template())
    this
    
  bind: ->
    $(@el).bind 'page:show', (event,page_id) =>
      @show(page_id) if page_id == "root"
    
  show: (id) ->
    @.$('.view-container').removeClass('active')
    @.$(".view-container[data-page-id=#{id}]").addClass('active')