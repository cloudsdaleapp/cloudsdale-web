class Cloudsdale.Views.CloudsUsersUser extends Backbone.View
  
  template: JST['clouds/users/user']
  
  model: 'user'
  topic: 'cloud'
  tagName: 'li'
  className: 'cloud-user'

  initialize: (args) ->
    
    args ||= {}
    
    @topic = args.topic
    @parentView = args.parentView

    @bindEvents()
    
    @haveBeenSeen()
    @queueForPurge()
    
    @render()
    
    @model.on('change',@render,this)
    

  render: ->
    $(@el).html(@template(model: @model)).attr('data-entity-id',@model.id)
    this

  bindEvents: ->
    $(@el).bind "#{@topic.type}s:#{@topic.id}:users:#{@model.id}", (event,payload) =>
      @model.set(payload)
      @haveBeenSeen()
    .bind 'click', (event) ->
      false
    
    this

  unbindEvents: ->
    this

  refreshGfx: ->
    this

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