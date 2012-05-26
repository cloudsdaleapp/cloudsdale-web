class Cloudsdale.Views.CloudsProsecutionDialog extends Backbone.View

  template: JST['clouds/chat/prosecution_dialog']

  model: 'prosecution'
  tagName: 'div'
  className: 'chat-dialog'
  
  events:
    'click .dialog-actions > a' : 'performVote'
  
  initialize: (args) ->
    
    @trialLength = 3
    @timeLeft = @trialLength
    
    @render()
    @bindEvents()
    @refreshGfx()
  
  render: ->
    $(@el).html(@template(model: @model))
    this
  
  bindEvents: ->
    @startTimer =>
      @requestVerdict()
      
  tickTimer: (callback) ->
    setTimeout =>
      @timeLeft -= 1
      @refreshGfx()
      if @timeLeft > 0 then  @tickTimer(callback) else callback()
    , 1000

  startTimer: (callback) ->
    @tickTimer(callback)
  
  refreshGfx: ->
    @.$('.chat-dialog-timer').text(@timeLeft)
  
  requestVerdict: ->
    @model.save()
  
  performVote: (event) ->
    @model.vote $(event.target).data('vote-value')
