$(document).bind 'index_admin.load', (e,obj) =>
  #$('ul.nav.nav-tabs').tabs()
  $('input#date_range').daterangepicker
    dateFormat: 'd/m/yy'
    onChange: ->
      $('form#date_select').submit()
  
  $('form#date_select').bind 'ajax:complete', (request,response) ->
    $("[data-statistics-container]").html(response.responseText)
  