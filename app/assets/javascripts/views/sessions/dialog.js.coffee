class Cloudsdale.Views.SessionsDialog extends Backbone.View
 
  template: JST['sessions/dialog']

  tagName: 'div'
  className: 'modal-container'
    
  events:
    'click a.auth-dialog-help-one'  : 'triggerAction'
    'click a.auth-dialog-help-two'  : 'triggerAction'
    'click a.auth-dialog-cancel'    : 'cancelDialog'
    'click button.auth-submit'      : 'submitFormFromState'

  initialize: (args) ->
    args = {} unless args
    @state = args.state || "login"
    
    @session = window.session
    @user = @session.get('user')
    
    @logoutOnHide = false
    
    @render()
    @toggleStateFromAction(@state)
    @bindEvents()
    
  render: ->
    $(@el).html(@template(session: @session, user: @user))
    this
  
  bindEvents: ->
    @.$('.modal').modal().bind 'hide', =>
      @.$('.input-group').tooltip('hide')
      window.setTimeout =>
        @logoutUser() if @logoutOnHide
        $(@el).remove()
      , 500
      
  refreshGfx: ->
    @clearLastState()
    if @state == 'restore'
      @.$("button.auth-submit").text("Restore")
      @.$("a.auth-dialog-help-one").text("Register an account").data('auth-dialog-state','register')
      @.$("a.auth-dialog-help-two").text("Use an existing account").data('auth-dialog-state','login')
      
    else if @state == 'register'
      @.$("button.auth-submit").text("Continue")
      @.$("a.auth-dialog-help-one").text("Forgot password?").data('auth-dialog-state','restore')
      @.$("a.auth-dialog-help-two").text("Use an existing account").data('auth-dialog-state','login')
    
    else if @state == 'complete'
      @.$("button.auth-submit").text("Complete Registration")
      @.$("a.auth-dialog-cancel").text("Cancel")
      
    else
      @.$("button.auth-submit").text("Login")
      @.$("a.auth-dialog-help-one").text("Forgot password?").data('auth-dialog-state','restore')
      @.$("a.auth-dialog-help-two").text("Register an account").data('auth-dialog-state','register')
    
  
  triggerAction: (e) ->
    action = @.$(e.target).data('auth-dialog-state')
    @toggleStateFromAction(action)
    
  toggleStateFromAction: (action) ->
    
    switch action
      when "restore"          then @toggleRestore()
      when "register"         then @toggleRegister()
      when "login"            then @toggleLogin()
      when "complete"         then @toggleComplete()
      
    false
      
  
  toggleRestore: ->
    @state = 'restore'
    @logoutOnHide = false
    @refreshGfx()
    @.$('form').addClass('auth-form-restore')
    false

  toggleRegister: ->
    @state = 'register'
    @logoutOnHide = false
    @refreshGfx()
    @.$('form').addClass('auth-form-register')
    false

  toggleLogin: ->
    @state = 'login'
    @logoutOnHide = false
    @refreshGfx()
    @.$('form').addClass('auth-form-login')
    false
  
  toggleComplete: ->
    @state = 'complete'
    @logoutOnHide = true
    @refreshGfx()
    @.$('form').addClass('auth-form-complete')
    false
  
  
  cancelDialog: () ->
    @hide() if $.inArray(@state, ["complete","password_change","name_change"]) >= 0
  
  logoutUser: ->
    window.location.replace('/logout')
    
  hide: (args) =>
    args = {} unless args
    @logoutOnHide = args.logout if args.logout != undefined
    
    @.$('.modal').modal('hide')
    false
  
  clearLastState: ->
    @.$('form').removeClass('auth-form-login').removeClass('auth-form-register').removeClass('auth-form-restore')
    false
    
  submitFormFromState: (e) ->
    switch @state
      when "restore"          then @submitRestore()
      when "register"         then @submitRegister()
      when "login"            then @submitLogin()
      when "complete"         then @submitComplete()
      
    e.preventDefault()
    false
  
  submitRestore: ->
    
    submitData = {}
    submitData.email = @.$('#session_email').val()
    
    $.ajax
      type: 'POST'
      url: "/v1/users/restore.json"
      data: submitData
      dataType: "json"
      success: (response) =>
        @hide(logout: false)
      error: (response) =>
        resp = $.parseJSON(response.responseText)
        @.$('.input-group').tooltip(
          placement: 'top'
          trigger: 'manual'
          animation: false
          title: "Something went wrong... try again later."
        ).tooltip('show')
    
  submitRegister: ->
    
    submitData = {}
    submitData.user = {}
    submitData.user.name = @.$('#session_password').val()
    submitData.user.email = @.$('#session_email').val()
    submitData.user.password = @.$('#session_password').val()
    
  submitLogin: ->
    
    submitData = {}
    submitData.email = @.$('#session_email').val()
    submitData.password = @.$('#session_password').val()
    submitData.persist_session = true
    
    $.ajax
      type: 'POST'
      url: "/v1/sessions.json"
      data: submitData
      dataType: "json"
      success: (response) =>
        userData = response.result.user
        session.get('user').set(userData)
        session.reInitializeClouds()
        @hide(logout: false)
      error: (response) =>
        resp = $.parseJSON(response.responseText)
        @.$('.input-group').tooltip(
          placement: 'top'
          trigger: 'manual'
          animation: false
          title: resp.flash.title + " " + resp.flash.message
        ).tooltip('show')
          
        switch resp.status
          # when 401
          #   # do stuff
          when 403
            @logoutUser()
          # when 500
          #   # do stuff
              
  submitComplete: ->
    submitData = {}
    submitData.user = {}
    submitData.user.name = @.$('#session_password').val()
    submitData.user.email = @.$('#session_email').val()
    submitData.user.password = @.$('#session_password').val()
    submitData.user.confirm_registration = true
    
    $.ajax
      type: 'PUT'
      url: "/v1/users/#{session.get('user').id}.json"
      data: submitData
      dataType: "json"
      success: (response) =>
        userData = response.user
        session.get('user').set(userData)
        @hide(logout: false)
      error: (response) =>
        resp = $.parseJSON(response.responseText)
        @.$('.input-group').tooltip(
          placement: 'top'
          trigger: 'manual'
          animation: false
          title: resp.flash.title + " " + resp.flash.message
        ).tooltip('show')
          
        switch resp.status
          # when 422
          #   # do stuff
          when 403
            @logoutUser()
          # when 500
          #   # do stuff
              