class Cloudsdale.Views.CloudsUsers extends Backbone.View

  template: JST['clouds/users']

  model: 'cloud'
  tagName: 'div'
  className: 'cloud-user-list-wrapper'

  initialize: (args) ->

    @render()

    @model.users
      success: (messages) =>
        @bindEvents()
        @refreshGfx()

        @.$('.loading-content.loader-users').addClass('load-ok')
        setTimeout ->
          @.$('.loading-content.loader-users').remove()
        , 500

      error: (messages) => @.$('.loading-content.loader-users').addClass('load-error')

  render: ->
    $(@el).html(@template(model: @model)).attr('data-entity-id',@model.id)
    this

  bindEvents: ->
    @.$(@el).mousewheel (event, delta) ->
      @scrollTop -= (delta * 30)
      event.preventDefault()

    nfc.on "#{@model.type}s:#{@model.id}:users:*", (payload) =>
      @refreshPresence(payload)

    this

  unbindEvents: ->
    this

  refreshGfx: ->
    this

  refreshPresence: (payload) ->
    user = session.get('users').findOrInitialize(payload)

    if @.$("ul.cloud-user-list > li.cloud-user[data-entity-id='#{payload.id}']").length > 0
      $.event.trigger "#{@model.type}s:#{@model.id}:users:#{payload.id}", payload
    else
      view = new Cloudsdale.Views.CloudsUsersUser(model: user, topic: @model, parentView: this)
      @.$('ul.cloud-user-list').append(view.el)

    @reorderList()

    this

  reorderList: ->

    _elements = @.$("ul.cloud-user-list > li")
    _elements.sort (a, b) ->

      compA = $(a).find('a > span').text().toUpperCase()
      compB = $(b).find('a > span').text().toUpperCase()

      return (if (compA < compB) then -1 else (if (compA > compB) then 1 else 0))

    @.$("ul.cloud-user-list").append(_elements)

    _elements = @.$("ul.cloud-user-list > li")
    _elements.sort (a,b) ->
      posA = $(a).attr('data-role')
      posB = $(b).attr('data-role')

      compA = if typeof posA == 'string' then parseInt(posA) else 1000
      compB = if typeof posB == 'string' then parseInt(posB) else 1000
      return (if (compA < compB) then -1 else (if (compA > compB) then 1 else 0))

    @.$("ul.cloud-user-list").append(_elements)


  # Refresh the GFX in the sidebar
  #
  # Returns false.
  # refreshSidebarGFX: ->
  #   users_online = @.$(".chat-online-list").children().length
  #   @.$(".chat-sidebar-header > span.chat-sidebar-online-count > span.n").html("#{users_online}")
  #   false
