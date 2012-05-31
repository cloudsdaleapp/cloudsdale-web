class Cloudsdale.Models.Session extends Backbone.Model
  
  defaults:
    user: {}
    clouds: []
    users: []
  
  initialize: (attr) ->
    
    @set 'user', new Cloudsdale.Models.User(@get('user'))
    
    @set 'users', new Cloudsdale.Collections.Users()
    @set 'clouds', new Cloudsdale.Collections.Clouds()
    
    
    @get('users').add(@get('user'))
    @listenToPrivateChannel()
    
    @bindEvents()
    @reInitializeClouds()
      
  listenToPrivateChannel: ->
    if @isLoggedIn()
      nfc.on "users:#{@get('user').id}:private", (payload) =>
        @get('user').set(payload)
  
  bindEvents: ->
      
    @get('user').on 'change', (user) =>
      window.location.replace("/logout") if user.get('is_banned')
      @listenToPrivateChannel() 
  
  # Returns true if the user is not a new user.
  isRegistered: -> @get('user').get('is_registered')
  
  # Returns true if the session user is an actual record
  isLoggedIn: -> @get('user').get('is_transient') == false
  
  # Returns true if user is affiliated with any clouds.
  hasClouds: -> @get('clouds').length > 1
  
  reInitializeClouds: ->
    @set 'clouds', new Cloudsdale.Collections.Clouds(@get('user').get('clouds'))
    $.event.trigger 'clouds:initialize'
  
  isModerator: ->
    $.inArray(@get('user').get('role'),["admin","moderator","creator"]) > -1
  
  isAdmin: ->
    $.inArray(@get('user').get('role'),["creator","admin"]) > -1