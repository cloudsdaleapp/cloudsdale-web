class DropReflection

  constructor: (@frame,args) ->
    @deleteButton = @frame.find('.drop-reflection-delete')
    
    @bind()
    
  bind: =>
    @deleteButton.bind 'ajax:complete', (request,response) =>
      if response.status == 200
        response_data = $.parseJSON(response.responseText)
        @frame.fadeOut(200)
        setTimeout =>
          @frame.remove()
        ,200
        
        
        #console.log $("li##{response_data.reflection._id}")
        #@reflectionsList.append(response.responseText)

$.fn.dropReflection = ->
  new DropReflection(@,arguments[0])