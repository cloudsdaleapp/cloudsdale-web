class Cloudsdale.Views.RootSession extends Backbone.View

  template: JST['root/session']
  className: 'span12 root-get-started'

  events:
    'click .root-trigger-saddle-up' : -> @openSessionDialog('register')
    'click .root-trigger-avatar'    : -> @openSettingsDialog('avatar')
    'click .root-trigger-settings'  : -> @openSettingsDialog('general')
    'click .root-trigger-tnc'       : -> @openTncDialog()
    'click .root-trigger-explore'   : -> @goToExplorePage()

  steps:
    avatar:
      id: 'avatar'
      name: 'Avatar'
      number: 1
      percent: 20

    tnc:
      id: 'tnc'
      name: 'Terms & Conditions'
      number: 2
      percent: 50

    explore:
      id: 'explore'
      name: 'Clouds'
      number: 3
      percent: 75


  totalSteps: 3

  initialize: (args) ->
    @render()
    @bindEvents()

  render: ->
    @determineStep()
    $(@el).html(@template(view: @, step: @step))
    this

  bindEvents: ->
    session.get('user').on 'change', (user) => @render()

  determineStep: ->
    if session.get('user').get('has_an_avatar') == false
      @step = @steps['avatar']
    else if session.get('user').get('has_read_tnc') == false
      @step = @steps['tnc']
    else if session.get('user').get('is_member_of_a_cloud') == false
      @step = @steps['explore']
    else
      @step = undefined

  openSessionDialog: (state) ->
    view = new Cloudsdale.Views.SessionsDialog(state: state).el
    if $('.modal-container').length > 0 then $('.modal-container').replaceWith(view) else $('body').append(view)
    false

  openSettingsDialog: (state) ->
    view = new Cloudsdale.Views.UsersSettingsDialog(state: state).el
    if $('.modal-container').length > 0 then $('.modal-container').replaceWith(view) else $('body').append(view)
    false

  openTncDialog: () ->
    view = new Cloudsdale.Views.RootTncDialog().el
    if $('.modal-container').length > 0 then $('.modal-container').replaceWith(view) else $('body').append(view)
    false

  goToExplorePage: ->
    Backbone.history.navigate("/explore",true)
    false
