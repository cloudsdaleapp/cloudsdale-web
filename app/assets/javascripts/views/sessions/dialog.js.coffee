class Cloudsdale.Views.SessionsDialog extends Backbone.View
 
  template: JST['sessions/dialog']

  tagName: 'div'
  className: 'modal-container'
    
  events:
    'click a.auth-dialog-help-one'  : 'triggerAction'
    'click a.auth-dialog-help-two'  : 'triggerAction'
    'click a.auth-dialog-cancel'    : 'hide'
    'click button.auth-submit'      : 'submitFormFromState'

  initialize: (args) ->
    args = {} unless args
    @state = args.state || "login"
    
    @session = window.session
    @user = @session.get('user')
    
    @render()
    @toggleStateFromAction(@state)
    @bindEvents()
    
    
  render: ->
    $(@el).html(@template(session: @session, user: @user))
    this
  
  bindEvents: ->
    @.$('.modal').modal().bind 'hide', =>
      @.$('.input-group').tooltip('hide')
      window.setTimeout ->
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
      when "restore" then @toggleRestore()
      when "register" then @toggleRegister()
      when "login" then @toggleLogin()
      when "complete" then @toggleComplete()
    false
      
  
  toggleRestore: ->
    @state = 'restore'
    @refreshGfx()
    @.$('form').addClass('auth-form-restore')
    false

  toggleRegister: ->
    @state = 'register'
    @refreshGfx()
    @.$('form').addClass('auth-form-register')
    false

  toggleLogin: ->
    @state = 'login'
    @refreshGfx()
    @.$('form').addClass('auth-form-login')
    false
  
  toggleComplete: ->
    @state = 'complete'
    @refreshGfx()
    @.$('form').addClass('auth-form-complete')
    false
  
  hide: ->
    @.$('.modal').modal('hide')
    false
  
  clearLastState: ->
    @.$('form').removeClass('auth-form-login').removeClass('auth-form-register').removeClass('auth-form-restore')
    false
    
  submitFormFromState: (e) ->
    switch @state
      when "restore"  then @submitRestore()
      when "register" then @submitRegister()
      when "login"    then @submitLogin()
      when "complete" then @submitComplete()
      
    e.preventDefault()
    false
  
  submitRestore: ->
    
    submitData = {}
    submitData.email = @.$('#session_email').val()
    
    $.ajax
      type: 'POST'
      url: "/v1/users/restore"
      data: submitData
      dataType: "json"
      success: (response) =>
        @hide()
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
      url: "/v1/sessions"
      data: submitData
      dataType: "json"
      success: (response) =>
        userData = response.result.user
        session.get('user').set(userData)
        @hide()
      error: (response) =>
        resp = $.parseJSON(response.responseText)
        @.$('.input-group').tooltip(
          placement: 'top'
          trigger: 'manual'
          animation: false
          title: resp.flash.title + " " + resp.flash.message
        ).tooltip('show')
          
        switch resp.status
          when 401 then false
          when 403 then false
          when 500 then false
      
    
  submitComplete: ->
    
    submitData = {}
    submitData.user = {}
    submitData.user.name = @.$('#session_password').val()
    submitData.user.email = @.$('#session_email').val()
    submitData.user.password = @.$('#session_password').val()
    
    