class Cloudsdale.Views.CloudsProsecutionDialog extends Backbone.View
  
  template: JST['clouds/prosecution_dialog']
  
  model: 'prosecution'
  tagName: 'div'
  className: 'container-inner container-inner-secondary'

  events:
    'click a.close[data-dismiss="dialog"]' : "close"
    'click a[data-action="saveAndGoToTrial"]' : 'saveAndGoToTrial'
    'click a[data-action="saveWithoutTrial"]' : 'saveWithoutTrial'
  
  initialize: (args) ->
    
    @render()
    @bindEvents()
    
    this
  
  render: ->
    $(@el).html(@template(model: @model))
    
    resizeBottomWrapper(@.$('.cloud-sidebar-bottom'))
    
    @.$('#prosecution_sentence_due_date').datepicker
      weekStart: 1
    
    @.$('#prosecution_sentence_due_time').timepicker
      showSeconds: true
      showMeridian: false
      showInputs: false
    
    this
  
  bindEvents: ->
    @model.on 'change', (event,prosecution) => @render()
  
  close: ->
    $(@el).parent().removeClass('show-secondary')
    setTimeout =>
      $(@el).remove()
    , 400
    false
  
  saveModel: (args,options) ->
    args = {} unless args
    options = {} unless options
    
    $(@el).prepend('<div class="loading-content" />')
    
    @model.save(args,options)
  
  saveAndGoToTrial: ->
    @saveModel(@fetchFormData())
    false
    
  saveWithoutTrial: ->
    @saveModel(@fetchFormData())
    false
  
  fetchFormData: ->
    data = @.$('form').serializeObject()
    data.sentence_due = new Date("#{data.sentence_due_date} #{data.sentence_due_time}").toString()
    delete data["sentence_due_date"]
    delete data["sentence_due_time"]
    data