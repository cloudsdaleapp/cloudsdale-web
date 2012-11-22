class Cloudsdale.Views.CloudsUserDialog extends Backbone.View

  template: JST['clouds/user_dialog']

  model: 'user'
  tagName: 'div'
  className: 'container-inner scroll-vertical container-sidebar'

  events:
    'click a.close[data-dismiss="dialog"]' : "close"
    'click a[data-action="moderate"]' : 'toggleUserModeration'
    'click a[data-action="skype:add"]' : 'skypeAdd'
    'click a[data-action="skype:call"]' : 'skypeCall'

  initialize: (args) ->

    @topic = args.topic if args.topic

    @newBan = new Cloudsdale.Models.Ban
      enforcer: session.get('user')
      jurisdiction: @topic

    @currentBans = new Cloudsdale.Collections.Bans [], {
      url: "/v1/#{@topic.type}s/#{@topic.id}/bans.json?offender_id=#{@model.id}"
    }

    @render()
    @bindEvents()

    if @topic.isModerator(session.get('user'))
      @currentBans.fetch
        add: true
        success: (_collection) =>
          @.$('.sidebar-bans').removeClass('sidebar-loader')
          if _collection.length == 0
            @.$('.sidebar-bans').append("
              <p class='sidebar-lead'>
                This user's record for this cloud is spotless. If this user has been misbehaving, you have tools below to help you.
              </p>
            ")

    this

  render: ->
    $(@el).html(@template(model: @model, topic: @topic, newBan: @newBan))
    this

  bindEvents: ->

    @currentBans.on 'add', (ban) =>
      view = new Cloudsdale.Views.CloudsSidebarBan { model: ban }
      @.$('.sidebar-bans').append(view.el)

    @.$('#ban_due_date').datepicker
      weekStart: 1

    @.$('#ban_due_time').timepicker
      showSeconds: true
      showMeridian: false
      showInputs: false
      minuteStep: 1
      secondStep: 30

    @.$('#ban_form').bind 'submit', (e) =>
      @newBan.set(@fetchBanFormData())
      @newBan.save {},
        success: =>
          @close()
        error: (ban,resp,xhr) =>
          response = $.parseJSON(resp.responseText)
          @.$('#ban_errors').html("<div class='sidebar-form-errors'>
            #{@buildErrors(response.errors)}
          </div>")

      e.preventDefault()
      false

    @.$('#ban_form > :input[type=text], #ban_form > textarea').on 'focus', =>
      @.$('#ban_errors').html("")

  close: ->
    $(@el).parent().parent().removeClass('with-open-drawer')
    setTimeout =>
      $(@el).remove()
    , 400
    false

  toggleUserModeration: ->
    @.$('a[data-action="moderate"]').parent().toggleClass('active')

  skypeAdd: ->
    window.open("skype:#{@model.get('skype_name')}?add").close()
    false

  skypeCall: ->
    window.open("skype:#{@model.get('skype_name')}?call").close()
    false

  fetchBanFormData: ->
    data = @.$('#ban_form').serializeObject()

    data.offender_id  = @model.id
    data.due          = new Date("#{data.due_date} #{data.due_time}").toString()

    delete data["due_date"]
    delete data["due_time"]

    data

  buildErrors: (errors) ->
    t = "<ul style='text-align: left;'>"
    $.each errors, (index,error) ->
      t += "<li><strong>#{error.ref_node}</strong> #{error.message}</li>" if error.type == "field"
      t += "<li><strong>#{error.message}</strong></li>" if error.type == "general"
    t += "</ul>"
