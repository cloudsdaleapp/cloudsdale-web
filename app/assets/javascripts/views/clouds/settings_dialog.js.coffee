class Cloudsdale.Views.CloudsSettingsDialog extends Backbone.View

  template: JST['clouds/settings_dialog']

  tagName: 'div'
  className: 'container-inner scroll-vertical container-sidebar'

  events:
    'click a.close[data-dismiss="dialog"]' : "close"
    'click .remove-avatar' : "removeAvatar"
    'click .close.remove-mod' : "removeMod"

  initialize: (args) ->
    args = {} unless args

    @state = args.state || "general"
    @cloud = args.cloud

    @render()
    @bindEvents()
    @refreshGfx()

    this

  render: ->
    $(@el).html(@template(cloud: @cloud))

    @fixCheckboxes()

    @cloud.users
      success: (resp) =>
        @renderModerators()

        @.$('#cloud_moderators').select2
          data: _.map(resp, (_user) ->
            return _user.toSelectable()
          )
          multiple: false
          formatResult: @formatSelectResults
          formatSelection: @formatSelectResults
          initSelection: (element,callback) ->
            return callback(element)

        .on "change", (e) =>
          ids = @cloud.get('moderator_ids')
          ids.push(e.val)
          @saveCloud({ x_moderator_ids: ids },
            success: => @.$('#cloud_moderators').select2("val", "")
          )

    this

  refreshGfx: ->
    @.$('img.cloud-avatar').attr('src',@cloud.get('avatar').normal)
    @.$('h2.cloud-name').text(@cloud.get('name'))
    if @cloud.get('short_name')
      @.$('#cloud_short_name').attr('value',"/clouds/#{@cloud.get('short_name')}").attr('disabled','disabled')

  close: ->
    $(@el).parent().parent().removeClass('with-open-drawer')
    setTimeout =>
      $(@el).remove()
    , 400
    false

  bindEvents: ->

    @cloud.on 'change', (cloud,meta) =>
      @refreshGfx()
      @renderModerators()
      changes = if meta.changes then meta.changes else { short_name: false }
      if changes.short_name
        Backbone.history.navigate(@cloud.link(),true) if @cloud.get('short_name')

    $("body").on "click.tab.data-api", "[data-toggle=\"tab\"], [data-toggle=\"pill\"]", (e) ->
      e.preventDefault()
      $("a[href=#{$(@).attr('href')}]").tab "show"

    setTimeout =>
      @.$(".nav.nav-tabs a[href=#settings-#{@state}]").tab('show')
    , 0

    @.$(':checkbox').change ->
      unless $(@).data('preventAjax') == true
        submitData = {}
        submitData[@name] = if @checked then true else false
        $.event.trigger 'change:field:cloud', { element: @, submitData: submitData }

    @.$(':file').on 'change', => @submitAvatar()

    @.$(':text,:password,textarea').on 'change', (event) ->
      unless $(@).data('preventAjax') == true
        submitData = {}
        submitData[@name] = @value
        $.event.trigger 'change:field:cloud', { element: @, submitData: submitData }

    $(@el).bind 'change:field:cloud', (event,payload) =>
      submitData = payload.submitData
      elem = payload.element
      @clearFieldErrors(@.$(elem))

      @.$(elem).parent().addClass('loading-controls')

      @saveCloud(submitData,
        success: (cloud,response) =>
          @.$(elem).parent().removeClass('loading-controls')
        error: (cloud,response) =>
          @displayFieldErrorsFromResponse(response)
          @.$(elem).parent().removeClass('loading-controls')
      )

  fixCheckboxes: ->
    @.$('input[type=checkbox]').each (index,cbInput) =>
      _el   = @.$(cbInput)
      _val  = @cloud.get(_el.attr('name'))

      _el.attr('checked','checked') if _val && _val == true

    this

  renderModerators: ->
    @.$("ul.moderator_list > li").remove()
    $.each @cloud.moderators(), (i,user) =>
      @.$("ul.moderator_list").append("<li class='sidebar-item' data-userId='#{user.id}'>
        <a class='close remove-mod' href='#'>×</a>
        <a>
          <div class='sidebar-item-avatar' style='background-image: url(#{user.get('avatar').mini});' />
          <span class='sidebar-item-name'>#{user.get('name')}</span>
        </a>
      </li>")

  removeMod: (e) ->
    user_id = @.$(e.target).parent().attr('data-userId')
    moderator_ids = _.reject(@cloud.get('moderator_ids'), (mod_id) -> return mod_id == user_id)
    @saveCloud({ x_moderator_ids: moderator_ids }
      success: (resp) =>
        @renderModerators()
    )

  saveCloud: (attr,options) ->
    attr ||= {}
    options ||= {}
    options.wait = true
    @cloud.save(attr,options)

  removeAvatar: (event) =>
    unless @.$(event.target).attr('disabled') == 'disabled'
      @.$(event.target).attr('disabled','disabled')
      @cloud.removeAvatar
        success: =>
          @.$(event.target).attr('disabled',null)

    false

  submitAvatar: ->

    @.$('form#avatar-form').append('<div class="loading-content"/>')

    $.ajax
      url: "/v1/clouds/#{@cloud.id}.json"
      files: @.$(":file")
      iframe: true
      dataType: "application/json"
      complete: (response) =>
        @.$(":file").val('')
        @.$('form#avatar-form > .loading-content').remove()
        resp = $.parseJSON(response.responseText)
        switch resp.status
          when 200
            @cloud.set(resp.result)
            @.$('form#avatar-form .loading-content').addClass('load-ok')

  displayFieldErrorsFromResponse: (response) ->
    errors = $.parseJSON(response.responseText).errors
    $.each errors, (id,error) =>
      if error.type == "field"
        field = $("[name=#{error.ref_node}]")
        controls = field.parent().parent()

        controls.addClass('error')
        field.after("<span class='help-inline field-error-message'>#{error.message}</span>")

  clearFieldErrors: (field) ->
    controls = field.parent().parent()
    controls.removeClass('error')
    controls.find("span.help-inline.field-error-message").remove()

  formatSelectResults: (user) ->
    return "<img src='#{user.avatar}'/> <strong>#{user.text}</strong>"



