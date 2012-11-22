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

    @render()
    @bindEvents()

    this

  render: ->
    $(@el).html(@template(model: @model, topic: @topic, newBan: @newBan))

    @.$('#ban_due_date').datepicker
      weekStart: 1

    @.$('#ban_due_time').timepicker
      showSeconds: true
      showMeridian: false
      showInputs: false
      minuteStep: 1
      secondStep: 30

    this

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

  bindEvents: ->
    @model.on 'change', (event,user) =>
      @render()

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
