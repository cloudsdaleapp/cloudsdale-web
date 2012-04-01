#= require modules/search

do ($ = jQuery) ->
  class TopBar
    constructor: (@frame,args) ->
      @searchForm = @frame.find('form#search-main')
      @searchForm.searchable()
      
  $.fn.topBar = ->
    new TopBar(@,arguments[0])