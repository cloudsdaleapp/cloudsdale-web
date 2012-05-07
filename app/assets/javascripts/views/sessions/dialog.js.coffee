class Cloudsdale.Views.SessionsDialog extends Backbone.View
 
  template: JST['sessions/dialog']

  tagName: 'div'
  className: 'modal-container'
    
  events:
    'click a.auth-dialog-help-one' : 'triggerAction'
    'click a.auth-dialog-help-two' : 'triggerAction'

  initialize: ->
    @render()
    @refreshGfx()
    @bindEvents()
    
  render: ->
    $(@el).html(@template())
    @.$('form').addClass('auth-form-login')
    this
  
  bindEvents: ->
    @.$('.modal').modal()
  
  refreshGfx: ->
    if @.$("form").hasClass('auth-form-restore')
      @.$("button.auth-submit").text("Restore")
      @.$("a.auth-dialog-help-one").text("Register an account").data('auth-dialog-state','register')
      @.$("a.auth-dialog-help-two").text("Use an existing account").data('auth-dialog-state','login')
      
    else if @.$("form").hasClass('auth-form-register')
      @.$("button.auth-submit").text("Continue")
      @.$("a.auth-dialog-help-one").text("Forgot password?").data('auth-dialog-state','restore')
      @.$("a.auth-dialog-help-two").text("Use an existing account").data('auth-dialog-state','login')
      
    else
      @.$("button.auth-submit").text("Login")
      @.$("a.auth-dialog-help-one").text("Forgot password?").data('auth-dialog-state','restore')
      @.$("a.auth-dialog-help-two").text("Register an account").data('auth-dialog-state','register')
    
  
  triggerAction: (e) ->
    action = @.$(e.target).data('auth-dialog-state')
    switch action
      when "restore" then @toggleRestore()
      when "register" then @toggleRegister()
      when "login" then @toggleLogin()
      
  
  toggleRestore: ->
    @state = 'restore'
    @clearLastState()
    @.$('form').addClass('auth-form-restore')
    @refreshGfx()
    false

  toggleRegister: ->
    @state = 'register'
    @clearLastState()
    @.$('form').addClass('auth-form-register')
    @refreshGfx()
    false

  toggleLogin: ->
    @state = 'login'
    @clearLastState()
    @.$('form').addClass('auth-form-login')
    @refreshGfx()
    false
  
  clearLastState: ->
    @.$('form').removeClass('auth-form-login').removeClass('auth-form-register').removeClass('auth-form-restore')
    