class Cloudsdale.Views.CloudsUsersSidebar extends Backbone.View

  template: JST['clouds/users_sidebar']

  model: 'cloud'
  collection: 'users'

  tagName: 'div'
  className: 'container-inner scroll-vertical container-sidebar'

  events:
    'click a[data-dismiss="dialog"]'       : "close"
    'click a[data-action="expandMods"]'    : 'expandMods'
    'click a[data-action="expandMembers"]' : 'expandMembers'
    'submit form' : 'submitForm'
    'keyup input' : 'doSearch'

  initialize: (args) ->

    args = {} unless args

    @render()
    @bindEvents()
    @refreshGfx()

    this

  render: ->
    $(@el).html(@template(
      model: @model,
      collection: @collection
    )).attr('data-entity-id',@model.id)

    @collection.each (model,collection) =>
      @renderUser(model)

    this

  bindEvents: ->
    @.$(@el).mousewheel (event, delta) ->
      @scrollTop -= (delta * 30)
      event.preventDefault()

    @collection.on 'add', (model) =>
      @renderUser(model)

    this

  refreshGfx: ->
    # _.each @.$('.sidebar-list'), ->
    #   $(@).removeClass('sidebar-loader') if $(@).children().length >= 1

    users_online = @.$(".sidebar-item[data-status='0']").length
    @.$(".cloud-user-sidebar-online-count").html("(#{users_online}/#{@model.get('member_count')})")
    false

  close: ->
    $(@el).parent().parent().removeClass('with-open-drawer')
    setTimeout =>
      $(@el).remove()
    , 400
    false

  submitForm: (e) ->
    @doSearch()
    e.preventDefault()
    false

  doSearch: (e) ->
    query = @.$('form input').attr('value') || ""

    if query && query.length >= 1
      @.$('.cloud-moderator-list, .cloud-member-list').addClass('search-in-progress')
      regexQuery = new RegExp(query,"i")

      $.each @.$('.sidebar-item'), (_el) ->
        nameBlock = $(@).find('span.sidebar-item-name')

        if nameBlock
          text = nameBlock.attr('data-originalText')
          result = text.match(regexQuery)

          if result
            $(@).addClass('search-matching')
            formatted = "<strong style='color: white;'>#{result[0]}</strong>"
            nameBlock.html(text.replace(result[0],formatted))

          else
            $(@).removeClass('search-matching')
            nameBlock.text(text)
    else
      @.$('.cloud-moderator-list, .cloud-member-list').removeClass('search-in-progress')



  renderUser: (user) ->
    view = new Cloudsdale.Views.CloudsSidebarUser(model: user).el
    if @model.isModerator(user)
      if @.$(".cloud-moderator-list > li[data-userId='#{user.id}']").length < 1
        @.$('.cloud-moderator-list').append(view)
        @reorderList(@.$('.cloud-moderator-list'))

    else
      if @.$(".cloud-member-list > li[data-userId='#{user.id}']").length < 1
        @.$('.cloud-member-list').append(view)
        @reorderList(@.$('.cloud-member-list'))

  reorderList: (_elem) ->
    _children = _elem.children()

    _children.sort (a, b) ->

      compA = $(a).find('span.sidebar-item-name').text().toUpperCase()
      compB = $(b).find('span.sidebar-item-name').text().toUpperCase()

      return (if (compA < compB) then -1 else (if (compA > compB) then 1 else 0))

    _elem.append(_children)

    _children = _elem.children()
    _children.sort (a,b) ->
      posA = $(a).attr('data-status')
      posB = $(b).attr('data-status')

      compA = if typeof posA == 'string' then parseInt(posA) else 1000
      compB = if typeof posB == 'string' then parseInt(posB) else 1000
      return (if (compA < compB) then -1 else (if (compA > compB) then 1 else 0))

    _elem.append(_children)

  expandMods: ->
    @.$('a[data-action="expandMods"]').toggleClass('active')
    @.$('.cloud-moderator-list').toggleClass('active')

  expandMembers: ->
    @.$('a[data-action="expandMembers"]').toggleClass('active')
    @.$('.cloud-member-list').toggleClass('active')
