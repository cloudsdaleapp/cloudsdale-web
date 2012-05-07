class Cloudsdale.Views.SessionsDialog extends Backbone.View
 
  template: JST['sessions/dialog']

  tagName: 'div'
  className: 'modal-container'
    
  events:
    'click a.auth-dialog-help-one' : 'triggerAction'
    'click a.auth-dialog-help-two' : 'triggerAction'

  initialize: (args) ->
    args = {} unless args
    @state = args.state || "login"
    
    @render()
    @toggleStateFromAction(@state)
    @bindEvents()
    
    
  render: ->
    $(@el).html(@template())
    this
  
  bindEvents: ->
    @.$('.modal').modal()
  
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
  
  clearLastState: ->
    @.$('form').removeClass('auth-form-login').removeClass('auth-form-register').removeClass('auth-form-restore')
    