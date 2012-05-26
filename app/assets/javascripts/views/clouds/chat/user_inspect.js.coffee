class Cloudsdale.Views.CloudsChatUserInspect extends Backbone.View
  
  template: JST['clouds/chat/user_inspect']
  
  model: 'user'
  tagName: 'div'
  className: 'chat-inspect-content'
  
  events:
    'click a.btn.btn-small[data-action]' : 'runAction'
  
  initialize: (args) ->
    
    @topic = args.topic
    @model = session.get('users').findOrInitialize(args.model)
    @render()
    @bindEvents()
  
  render: ->
    
    $(@el).html(@template(model: @model, topic: @topic)).attr('data-user-id',@model.id)
    this
  
  bindEvents: ->
    
    @model.on 'change', (event,user) =>
      @render()
  
  runAction: (event) ->
    
    action = @.$(event.target).data('action')
    
    switch action
      when 'vote' then alert("MAKE A VOTE")
      when 'ban' then @toggleUserBan()
      when 'close' then @hideFrame()
      
    false
  
  toggleUserBan: ->
    
    @.$('a.btn.btn-small[data-action=ban]').attr('disabled','disabled')
    
    if @model.get('is_banned')
      @model.unban
        success: (user) =>
          @model.set(user)
          
    else
      @model.ban
        success: (user) =>
          @model.set(user)
  
  hideFrame: ->
    $(@el).remove()