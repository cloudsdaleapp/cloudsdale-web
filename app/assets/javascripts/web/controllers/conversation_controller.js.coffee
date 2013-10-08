Cloudsdale.ConversationController = Ember.Controller.extend
  actions:
    add: ->
      console.log "ADDED!"
      @transitionToRoute('root')
    remove: ->
      console.log "REMOVED!"
      @transitionToRoute('root')

