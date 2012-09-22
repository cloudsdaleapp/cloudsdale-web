class Cloudsdale.Views.RootNotification extends Backbone.View
  
  template: JST['root/notification']
  
  tagName: 'li'
  className: 'notification'
    
  events:
    'click a[data-dismiss="notification"]' : 'close'
    
  initialize: (args) ->
    
    args = {} unless args
    
    @header = if args.header then args.header else "Notification"
    @body   = if args.body then args.body else "Here you can put something..."
    @callback  = if args.callback then args.callback else (-> alert("CLICKED!"))
    
    @render()
    @bindEvents()
  
  render: ->
    $(@el).html(@template(header: @header, body: @body, links: @links))
    @.$('.notification-header').html(@header)
    @.$('.notification-body').html(@body)
    this
  
  bindEvents: ->
    $(@el).bind 'click', (event) =>
      unless @.$(event.target).hasClass("close")
        @callback()
        @close()
      false
  
  close: ->
    @remove()
    $.event.trigger "notifications:remove"
    false