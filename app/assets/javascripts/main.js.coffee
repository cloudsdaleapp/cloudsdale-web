#= require modules/dropzone

$(document).bind 'index_main.load', (e,obj) =>
  $('.dropzone').dropZone()
  $('li.drop').rainDrop()