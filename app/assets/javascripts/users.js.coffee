# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).bind 'edit_users.load', (e,obj) =>

$(document).bind 'show_users.load', (e,obj) =>
  $('.dropzone').dropZone()

$(document).bind 'new_users.load', (e,obj) =>
  $("fieldset").not('.active').hide()
  
  $('.form_part_next').bind 'click', ->
    $(@).parent()
    valid = false
    $("fieldset.active [data-validate]:input").each (k,v) ->
      settings = window[@form.id]
      valid = if $(this).isValid(settings.validators) then true else false
    if valid
      current = $('fieldset.active')
      current.removeClass('active').slideUp(300)
      current.next().addClass('active').slideDown(300)
      $("fieldset.active [data-validate]:input.error").tooltip('show')
  
  $('.form_part_previous').bind 'click', ->
    $("fieldset.active [data-validate]:input").tooltip('hide')
    current = $('fieldset.active')
    current.prev().addClass('active').slideDown(300)
    current.removeClass('active').slideUp(300)
    
    