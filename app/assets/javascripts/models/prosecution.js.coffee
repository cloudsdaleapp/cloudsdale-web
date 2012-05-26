class Cloudsdale.Models.Prosecution extends Backbone.Model
  
  url: -> "/v1/users/#{@get('offender').id}/prosecutions"
  
  defaults:
    argument: ""
    sentence: "ban"
    sentence_due: Date.new
  
  initialize: (args) ->
    
    super
    
    args ||= {}
    args.offender ||= {}
    args.prosecutor ||= {}
    
    if getObjectClass(args.offender) == "User"
      @set 'offender', args.offender
    else
      @set 'offender', new Cloudsdale.Models.User(args.offender)
    
    if getObjectClass(args.prosecutor) == "User"
      @set 'prosecutor', args.prosecutor
    else
      @set 'prosecutor', new Cloudsdale.Models.User(args.prosecutor)
    
    console.log @
    
  vote: (vote_value) ->
    $.ajax
      type: 'PUT'
      url: "/v1/users/#{@get('offender').id}/prosecutions/#{@id}/vote.json"
      data: { vote_value: vote_value }
      dataType: "application/json"
      success: (response) =>
        console.log response
        
      error: (response) =>
        console.log response
          
