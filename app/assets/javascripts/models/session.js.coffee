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
    @get('user').set('status',@get('user').get('preferred_status'))
    @listenToPrivateChannel()

    @bindEvents()
    @reInitializeClouds()

  listenToPrivateChannel: ->
    if @isLoggedIn()
      nfc.on "users:#{@get('user').id}:private", (payload) =>
        @get('user').set(payload)

  bindEvents: ->

    @get('user').on 'change', (user) =>
      user.set('status',@get('user').get('preferred_status'))
      window.location.replace("/logout") if user.get('is_banned')
      @listenToPrivateChannel()

    nfc.on "users:#{@get('user').id}:bans", (payload) =>

      ban = session.get('user').bans.findOrInitialize(payload)

      if ban.get('is_active')
        body = "You have been banned from #{ban.jurisdiction().get('name')} by
                #{ban.enforcer().get('name')}. Reason: #{ban.get('reason')}"
        callback = ->
          false
      else
        body = "Your ban from #{ban.jurisdiction().get('name')} has been revoked."
        callback = ->
          Backbone.history.navigate("/clouds/#{ban.jurisdiction().id}",true)
          false

      $.event.trigger "notifications:add", {
        header: "Attention!",
        body: body,
        callback: callback
        afterRender: (e) ->
          false
      }

      if ban.get('is_active')
        $.event.trigger "clouds:disable", ban.jurisdiction()
      else
        $.event.trigger "clouds:enable", ban.jurisdiction()

      return false

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
    $.inArray(@get('user').get('role'),["admin","moderator","founder","developer"]) > -1

  isAdmin: ->
    $.inArray(@get('user').get('role'),["founder","admin","developer"]) > -1
