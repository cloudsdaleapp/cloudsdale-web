class Cloudsdale.Models.Prosecution extends Backbone.Model
  
  url: -> "/v1/users/#{@offender().id}/prosecutions"
  
  defaults:
    argument: ""
    sentence: "ban"
    sentence_due: new Date
    is_transient: true
    crime_scene_id: undefined
    crime_scene_type: undefined
  
  initialize: (args,options) ->
        
    @set('argument',"#{@offender().get('name')} has ") unless @get('argument')
    
    super
    
  # vote: (vote_value) ->
  #   $.ajax
  #     type: 'PUT'
  #     url: "/v1/users/#{@get('offender').id}/prosecutions/#{@id}/vote.json"
  #     data: { vote_value: vote_value }
  #     dataType: "application/json"
  #     
  #     success: (response) =>
  #       console.log response
  #       
  #     error: (response) =>
  #       console.log response
  
  crimeScene: ->
    console.log @get('crime_scene_type')
    return session.get("#{@get('crime_scene_type')}s").findOrInitialize { id: @get('crime_scene_id') },
      fetch: false
  
  prosecutor: ->
    return session.get('users').findOrInitialize { id: @get('prosecutor_id') },
      fetch: false
  
  offender: ->
    return session.get('users').findOrInitialize { id: @get('offender_id') },
      fetch: false
  
  sentenceDueDate: ->
    @sentenceDue().toString("MM/dd/yyyy")
    
  sentenceDueTime: ->
    @sentenceDue().toString("hh:mm:ss")
    
  sentenceDue: ->
    new Date(@get('sentence_due'))
    
  toJSON: ->
    obj = 
      id: @id
      argument: @get('argument')
      sentence: @get('sentence')
      sentence_due: @sentenceDue()
      crime_scene_id: @get('crime_scene_id')
      crime_scene_type: @get('crime_scene_type')
      
    return obj