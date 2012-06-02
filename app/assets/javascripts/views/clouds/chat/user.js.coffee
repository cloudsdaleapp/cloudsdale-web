class Cloudsdale.Views.CloudsChatUser extends Backbone.View
  
  template: JST['clouds/chat/user']
  
  model: 'user'
  tagName: 'li'
  className: 'chat-user'
  
  events:
    'click a' : 'openUserInspect'
  
  initialize: (args) ->
    
    args ||= {}
    
    @topic = args.topic
    
    @bindEvents()
    
    @haveBeenSeen()
    
    @queueForPurge()
    
    @render()
    
    @model.on('change',@render,this)
  
  # Renders the template to the element.
  render: ->
    $(@el).html(@template(model: @model)).attr('data-user-id',@model.id)
    this
  
  # Binds specific events not bindable by backbone.
  #
  # Returns god knows what...
  bindEvents: ->
    $(@el).bind "#{@topic.type}s:#{@topic.id}:users:#{@model.id}", (event,payload) =>
      @model.set(payload)
      @haveBeenSeen()
  
  # Sets the timestamp of when the user was last seen
  #
  # Returns the timestamp as an integer.
  haveBeenSeen: ->
    @lastSeen = new Date().getTime()
  
  # Queues the user to be purged
  #
  # Returns false.
  queueForPurge: ->
    window.setTimeout ( =>
      
      @remove() if @lastSeen < new Date().getTime() - 35000
      
      setTimeout ( =>
        @queueForPurge()
      ), 25000
      
    ), 5000
    false
  
  openUserInspect: (event) ->
    $.event.trigger "clouds:#{@topic.id}:chat:inspect:user", @model
    false
    
    