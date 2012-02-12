# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).bind 'edit_users.load', (e,obj) =>

$(document).bind 'show_users.load', (e,obj) =>
  $('.dropzone').dropZone()
  $('li.drop').rainDrop()

$(document).bind 'new_users.load', (e,obj) =>
  $("fieldset").not('.active').hide()
  
  $('.form_part_next').bind 'click', ->
    $(@).parent()
    valid = true
    $("fieldset.active [data-validate]:input").each (k,v) ->
      settings = window[@form.id]
      valid = false unless $(this).isValid(settings.validators)
    
    if valid
      current = $('fieldset.active')
      current.removeClass('active').slideUp(300)
      current.next().addClass('active').slideDown(300)
      window.setTimeout ( =>
        $("fieldset.active [data-validate]:input.error").twipsy('show')
      ), 400
      
      
      
  
  $('.form_part_previous').bind 'click', ->
    $("fieldset.active [data-validate]:input").twipsy('hide')
    current = $('fieldset.active')
    current.prev().addClass('active').slideDown(300)
    current.removeClass('active').slideUp(300)
    
    