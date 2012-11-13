class Cloudsdale.Views.CloudsRulesDialog extends Backbone.View

  template: JST['clouds/rules_dialog']

  tagName: 'div'
  className: 'container-inner scroll-vertical container-sidebar'

  events:
    'click a.close[data-dismiss="dialog"]' : "close"

  initialize: (args) ->

    @render()

    this

  render: ->
    $(@el).html(@template(model: @model))

    resizeBottomWrapper(@.$('.cloud-sidebar-bottom'))

    if @model.get('rules')
      _content = JSON.stringify(@model.get('rules'))
      _content = _content.replace(/^"/,"").replace(/"$/,"").replace(/\\"/ig,'"').replace(/\\/ig,"\\")
      .replace(/\\n\\n/ig,"<br/>").replace(/\\n/ig,"<br/>")

    else
      _content = "Currently no rules set in this Cloud. Do remember the Terms & Conditions are not to be violated, regardless."

    @.$('p').html(_content)
    this

  close: ->
    $(@el).parent().parent().removeClass('with-open-drawer')
    setTimeout =>
      $(@el).remove()
    , 400
    false
