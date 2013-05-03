class Cloudsdale.Views.Root extends Backbone.View

  template: JST['root']

  tagName: 'body'

  initialize: ->
    @render()

    @topBarView = new Cloudsdale.Views.TopBar()
    @.$(".topnav").replaceWith(@topBarView.el)
    @.$('footer').html(footer_src)

    @bindEvents()
    @refreshGfx()

    @assertLogin()


  render: ->
    $(@el).html(@template())

    this

  bindEvents: ->

    $(@el).bind 'clouds:initialize', => @renderSidebar()

    $('a').live 'click', (e) ->
      if @hostname.match(document.location.hostname) != null && @pathname.match(/\/auth\/.*/ig) == null && @pathname.match(/\/logout/ig) == null
        Backbone.history.navigate(@pathname,true)
        e.preventDefault()
        false
      else
        this

    $(@el).bind 'page:show', (event,page_id) =>
      if page_id == 'page'
        $('.view-container').removeClass('active')
        $('.view-container#page-container').addClass('active')

    $(@el).bind 'notifications:add', (event,args) => @addNotification(args)
    $(@el).bind 'notifications:remove', (event,args) => @removeNotification(args)
    $(@el).bind 'notifications:clear', (event,args) => @clearNotifications(args)

    $(document).bind 'click', (event) -> $("body").removeClass('with-expanded-cloudbar')
    session.get('user').bind 'change', (user) => @refreshGfx()

  refreshGfx: ->
    if session.isLoggedIn() then $(@el).addClass('with-active-session') else $(@el).removeClass('with-active-session')

  show: (id) ->
    @.$('.view-container').removeClass('active')
    @.$(".view-container[data-page-id=#{id}]").addClass('active')

  openSessionDialog: (state) ->
    window.setTimeout =>
      view = new Cloudsdale.Views.SessionsDialog(
        state: state,
        callback: =>
          @assertLogin()
      ).el
      if @.$('.modal-container').length > 0 then @.$('.modal-container').replaceWith(view) else $(@el).append(view)
    , 100

  renderSidebar: ->
    _view = new Cloudsdale.Views.RootSidebar(model: session)
    @.$('.sidebar').replaceWith(_view.el)

  addNotification: (args) ->
    if @.$('.main-container > ul.notifications').length <= 0
      @.$('.main-container').append("<ul class='notifications'/>")

    view = new Cloudsdale.Views.RootNotification(args)
    @.$('ul.notifications').append(view.el)

    this

  removeNotification: (args) ->
    @.$('.main-container > ul.notifications').remove() if @.$('.main-container > ul.notifications > li').length <= 0

  clearNotifications: (args) ->
    this

  assertLogin: (args) ->
    if session.isLoggedIn()
      @renderSidebar()
      if session.get('user').get('needs_to_confirm_registration')
        @openSessionDialog('complete')
      else if session.get('user').get('needs_password_change')
        @openSessionDialog('password_change')
      else if session.get('user').get('needs_name_change')
        @openSessionDialog('name_change')
      else if session.get('user').get('needs_email_change')
        @openSessionDialog('email_change')

