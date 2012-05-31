class Cloudsdale.Views.CloudsShow extends Backbone.View
 
  template: JST['clouds/show']
  
  model: 'cloud'
  tagName: 'div'
  className: 'view-container'
  
  events: ->
    'click a.followed' : 'toggleFollow'
  
  initialize: ->
    
    @render()
    @bindEvents()
    
    @refreshGfx()
  
  render: ->
    $(@el).html(@template(model: @model)).attr('data-page-id',@model.id)
    this
  
  bindEvents: ->
    $(@el).bind 'page:show', (event,page_id) =>
      @show() if page_id == @model.id
    
    @model.on 'change', (model) =>
      @refreshGfx()
    
    session.get('user').on 'change', (model) =>
      @refreshGfx()
      
    $(@el).bind "clouds:leave", (event,cloud) =>
      if cloud.id == @model.id
        @unbindEvents()
        $(@el).remove()
  
  unbindEvents: ->
    $(@el).unbind('page:show').unbind("clouds:leave")
  
  refreshGfx: () ->
    @.$('.cloud-head img').attr('src',@model.get('avatar').normal)
    @.$('.cloud-head > h2').text(@model.get('name'))
    @.$('.cloud-head > p').text(@model.get('description'))
        
    "Member of Cloud: #{session.get('user').isMemberOf(@model)}"
    if session.get('user').isMemberOf(@model)
      @.$('a.followed').removeClass('btn-info').addClass('btn-danger').text('Leave Cloud').attr('data-action','leave')
    else
      @.$('a.followed').addClass('btn-info').removeClass('btn-danger').text('Add Cloud').attr('data-action','add')
  
  show: ->
    $('.view-container').removeClass('active')
    $(@el).addClass('active')
    
    if @.$('.chat-container').length == 0
      @chat_view = new Cloudsdale.Views.CloudsChat(model: @model)
      @.$('.float-container').html(@chat_view.el)
    else
      @chat_view.correctContainerScroll(true)
    
    if @.$('.drop-wrapper').children().length == 0
      @drop_view = new Cloudsdale.Views.CloudsDrops(model: @model)
      @.$('.drop-wrapper').replaceWith(@drop_view.el)
  
  toggleFollow: (event) ->
    switch @.$(event.target).attr('data-action')
      when 'add'
        session.get('user').add_cloud @model
      when 'leave'
        session.get('user').leave_cloud @model
        $.event.trigger "clouds:leave", @model
        Backbone.history.navigate("/",true)
            
    false
    
      
    