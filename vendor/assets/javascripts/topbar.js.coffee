do ($ = jQuery) ->
  class TopBar
    constructor: (@frame,args) ->
      @frame = @frame
      
  $.fn.topBar = ->
    new TopBar(@,arguments[0])