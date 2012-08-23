class Cloudsdale.Views.CloudsUsers extends Backbone.View
 
  template: JST['clouds/users']
  
  model: 'cloud'
  tagName: 'div'
  className: 'cloud-user-list-wrapper'
  
  initialize: (args) ->

    @render()
    @bindEvents()
    
    @refreshGfx()
  
  render: ->
    $(@el).html(@template(model: @model)).attr('data-entity-id',@model.id)
    this
  
  bindEvents: ->
    @.$(@el).mousewheel (event, delta) ->
      @scrollTop -= (delta * 30)
      event.preventDefault()
      
    nfc.on "#{@model.type}s:#{@model.id}:users:*", (payload) =>
      @refreshPresence(payload)
      
    this
    
  unbindEvents: ->
    this
  
  refreshGfx: ->
    this
  
  refreshPresence: (payload) ->
    if @.$("ul.cloud-user-list > li.cloud-user[data-entity-id='#{payload.id}']").length > 0
      $.event.trigger "#{@model.type}s:#{@model.id}:users:#{payload.id}", payload
    else
      user = session.get('users').findOrInitialize(payload)
      view = new Cloudsdale.Views.CloudsUsersUser(model: user, topic: @model, parentView: this)
      @.$('ul.cloud-user-list').append(view.el)
    
    this

  # Refresh the GFX in the sidebar
  # 
  # Returns false.
  # refreshSidebarGFX: ->
  #   users_online = @.$(".chat-online-list").children().length
  #   @.$(".chat-sidebar-header > span.chat-sidebar-online-count > span.n").html("#{users_online}")
  #   false