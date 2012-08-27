class Cloudsdale.Views.CloudsShow extends Backbone.View
 
  template: JST['clouds/show']
  
  model: 'cloud'
  tagName: 'div'
  className: 'view-container cloud-container'
  
  events:
    'click a.btn[data-action="settings"]' : 'toggleSettings'
    'click a.btn[data-action="rules"]'    : 'toggleRules'
    'click a.btn[data-action="drops"]'    : 'toggleDrops'
    'click a.btn[data-action="leave"]'    : 'leaveCloud'
    'click a.btn[data-action="destroy"]'  : 'destroyCloud'
      
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
    
    nfc.on "#{@model.type}s:#{@model.id}", (payload) =>
      @model.set(payload)
    
    $(@el).bind "#{@model.type}s:#{@model.id}:users:show", (event,_id) =>
      user = session.get('users').findOrInitialize { id: _id }
      @toggleUser(user)
    
  unbindEvents: ->
    $(@el).unbind('page:show').unbind("clouds:leave")
  
  refreshGfx: () ->
    @.$('.cloud-head img').attr('src',@model.get('avatar').normal)
    @.$('.cloud-head > h2').text(@model.get('name'))
    @.$('.cloud-head > p').text(@model.get('description'))
    
    resizeBottomWrapper(@.$('.cloud-sidebar-bottom'))
  
  show: ->
    $('.view-container').removeClass('active')
    $(@el).addClass('active')
    
    if @.$('.chat-wrapper').children().length > 0
      @chat_view.correctContainerScroll(true)
    else
      @chat_view = new Cloudsdale.Views.CloudsChat(model: @model)
      @.$('.float-container > .container-inner > .chat-wrapper').replaceWith(@chat_view.el)
      
    
    if @.$('.cloud-sidebar-bottom').children().length == 0
      @users_view = new Cloudsdale.Views.CloudsUsers(model: @model)
      @.$('.cloud-sidebar-bottom').append(@users_view.el)
    
    @refreshGfx()
  
  toggleSettings: (event) ->
    view = new Cloudsdale.Views.CloudsSettingsDialog(cloud: @model).el
    @renderDialog(view)
    
  toggleRules: (event) ->
    view = new Cloudsdale.Views.CloudsRulesDialog(model: @model).el
    @renderDialog(view)
  
  toggleDrops: (event) ->
    view = new Cloudsdale.Views.CloudsDropsDialog(model: @model).el
    @renderDialog(view)
  
  toggleUser: (_model) ->
    view = new Cloudsdale.Views.CloudsUserDialog(model: _model).el
    @renderDialog(view)
    
  renderDialog: (view) ->
    if @.$('.fixed-container > .container-inner.container-inner-secondary').length > 0
      @.$('.container-inner.container-inner-secondary').replaceWith(view)
    else
      @.$('.fixed-container').append(view)
    @.$('.fixed-container').addClass('show-secondary')
    false
    
  leaveCloud: (event) ->
    session.get('user').leaveCloud @model
    $.event.trigger "clouds:leave", @model
    Backbone.history.navigate("/",true)
    false
  
  destroyCloud: (event) ->
    answer = confirm "Are you sure you want to destroy #{@model.get('name')}"
    if answer == true
      $.event.trigger "clouds:leave", @model
      Backbone.history.navigate("/",true)
      @model.destroy()
    false
    
      
    