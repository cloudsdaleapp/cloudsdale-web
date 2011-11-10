# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  
  $('body.users.new .container').hide().delay(300).fadeIn(600)
  
  $('.form_part_next').bind 'click', ->
    $(@).parent()
    valid = true
    $(".row.form_part.active [data-validate]:input").each ->
      settings = window[@form.id]
      valid = false unless $(this).isValid(settings.validators)
    
    if valid
      current = $('.row.form_part.active')
      current.removeClass('active')
      current.next().addClass('active')
  
  $('.form_part_previous').bind 'click', ->
    current = $('.row.form_part.active')
    current.prev().addClass('active')
    current.removeClass('active')
    