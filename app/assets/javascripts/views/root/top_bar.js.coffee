class Cloudsdale.Views.TopBar extends Backbone.View

  template: JST['root/top_bar']

  className: 'topnav'

  events:
    'click a' : 'performAction'

  initialize: (args) ->
    @render()
    @bindEvents()
    @refreshGfx()

  render: ->
    $(@el).html(@template())
    this

  bindEvents: ->
    session.get('user').bind 'change', (user) =>
      @refreshGfx()

  refreshGfx: ->
    if session.isLoggedIn()
      @.$('li > a[data-navId=4]').addClass('nav-trigger-settings').removeClass('nav-trigger-login')
      @.$('li > a[data-navId=4]').data('action','settings')
      @.$('li > a[data-navId=4] > span').text('Settings')

      @.$('li > a[data-navId=3]').addClass('nav-trigger-clouds').removeClass('nav-trigger-register')
      @.$('li > a[data-navId=3]').data('action','clouds')
      @.$('li > a[data-navId=3] > span').text('Clouds')
    else
      @.$('li > a[data-navId=4]').addClass('nav-trigger-login').removeClass('nav-trigger-settings')
      @.$('li > a[data-navId=4]').data('action','login')
      @.$('li > a[data-navId=4] > span').text('Login')

      @.$('li > a[data-navId=3]').addClass('nav-trigger-register').removeClass('nav-trigger-clouds')
      @.$('li > a[data-navId=3]').data('action','register')
      @.$('li > a[data-navId=3] > span').text('Register')

  performAction: (event) ->

    unless $(event.target).data('action') == 'clouds'
      @collapseCloudBar()

    switch $(event.target).data('action')
      when 'home' then @goToRootPage()
      when 'explore' then @goToExplorePage()
      when 'info' then @goToInfoPage()
      when 'settings' then @openSettingsDialog()
      when 'clouds' then @toggleCloudExpand()
      when 'login' then @redirectToLogin()
      when 'register' then @redirectToRegister()

    false

  redirectToLogin: -> document.location = "/login"
  redirectToRegister: -> document.location = "/register"

  openSessionDialog: (state) ->
    view = new Cloudsdale.Views.SessionsDialog(state: state).el
    if $('.modal-container').length > 0 then $('.modal-container').replaceWith(view) else $('body').append(view)
    false

  openSettingsDialog: ->
    view = new Cloudsdale.Views.UsersSettingsDialog().el
    if $('.modal-container').length > 0 then $('.modal-container').replaceWith(view) else $('body').append(view)
    false

  toggleCloudExpand: (event) ->
    $('body').toggleClass('with-expanded-cloudbar')
    false

  collapseCloudBar: ->
    $('body').removeClass('with-expanded-cloudbar')

  goToRootPage: ->
    Backbone.history.navigate("/",true)
    false

  goToExplorePage: ->
    Backbone.history.navigate("/explore",true)
    false

  goToInfoPage: ->
    Backbone.history.navigate("/info",true)
    false
