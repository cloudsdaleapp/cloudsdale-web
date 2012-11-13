class Cloudsdale.Views.RootSidebar extends Backbone.View

  template: JST['root/sidebar']

  model: 'session'

  tagName: 'div'
  className: 'sidebar'

  initialize: (args) ->
    @render()
    @bindEvents()
    @initializeConversations()
    this

  render: ->
    $(@el).html(@template(model: @model))
    this

  bindEvents: ->
    $(@el).mousewheel (event, delta) ->
      @scrollTop -= (delta * 30)
      event.preventDefault()
    @.$('.sidebar-list').sortable
      axis: 'y'
      stop: (event, ui) =>
        @refreshListPositions()

    $(@el).bind 'clouds:join', (event,conversation) => @renderConversation(conversation)

    $(document).bind 'keydown', (e) =>

      activeToggle = @.$('.sidebar-item.active')

      if ((e.keyCode == 38) or (e.keyCode == 40)) and e.shiftKey

        if e.keyCode == 40
          next = activeToggle.next()
          if next.length > 0
            id = next.attr('data-entity-id')
            Backbone.history.navigate("/clouds/#{id}",true)

        if e.keyCode == 38
          prev = activeToggle.prev()
          if prev.length > 0
            id = prev.attr('data-entity-id')
            Backbone.history.navigate("/clouds/#{id}",true)

  initializeConversations: ->
    session.get('clouds').each (cloud) =>
      @renderConversation(cloud)

    @reorderClouds()
    @refreshListPositions()

  renderConversation: (conversation) ->

    if @.$("#sidebar-clouds.sidebar-list > li[data-entity-id=#{conversation.id}]").length == 0
      view = new Cloudsdale.Views.CloudsToggle(model: conversation)
      @.$('#sidebar-clouds.sidebar-list').append(view.el)

      conversation.announcePresence()

      # nfc.on "#{cloud.type}s:#{cloud.id}:prosecutions", (payload) =>
      #
      #   if payload.prosecutor_id != session.get('user').id
      #     _model = new Cloudsdale.Models.Prosecution(payload)
      #
      #     if _model.get('offender_id') == session.get('user').id
      #       _header = "You're under trial in #{_model.crimeScene().get('name')}"
      #       _body = "Click to follow the trial that will determine your sentence."
      #
      #     else
      #       _header = "#{_model.offender().get('name')} is under trial in #{_model.crimeScene().get('name')}"
      #       _body = "Click to participate in the trial and voice your opinion."
      #
      #     $.event.trigger "notifications:add", {
      #       header: _header,
      #       body: _body,
      #       callback: =>
      #         Backbone.history.navigate("/clouds/#{cloud.id}",true)
      #         $.event.trigger "#{cloud.type}s:#{cloud.id}:users:prosecution", _model
      #     }

  refreshListPositions: ->
    @.$("ul#sidebar-clouds > li").each (index,elem) =>
      _pos = @.$(elem).prevAll().length
      $.cookie "cloud:#{@.$(elem).attr('data-entity-id')}:toggle:pos", _pos,
        expires: 365
        path: "/"

  reorderClouds: ->
    _elements = @.$("ul#sidebar-clouds > li")
    _elements.sort (a,b) ->
      posA = $.cookie("cloud:#{$(a).attr('data-entity-id')}:toggle:pos")
      posB = $.cookie("cloud:#{$(b).attr('data-entity-id')}:toggle:pos")
      compA = if typeof posA == 'string' then parseInt(posA) else 1000
      compB = if typeof posB == 'string' then parseInt(posB) else 1000
      return (if (compA < compB) then -1 else (if (compA > compB) then 1 else 0))

    @.$("ul#sidebar-clouds").append(_elements)

  moveToggleFirst: (cloud) ->
    toggle = @.$("ul#sidebar-clouds > li.sidebar-item[data-entity-id=#{cloud.id}]")
    @.$('.sidebar > ul#sidebar-clouds').prepend(toggle)
