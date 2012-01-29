$(document).bind 'index_faqs.load', (e,obj) =>
  
  update_figures = () ->
    figures = []
    $('ul.faqs').children().each (i,p) ->
      pos = (i+1)
      $(@).find('span.position').text(pos)
      $(@).attr('data-position',pos)
      figures.push $(@).data()
    
    $.ajax
      type: 'POST'
      url: '/faqs/sort_figures'
      data: { 'figures' : JSON.stringify(figures) }
      dataType: 'JSON'
        
  $('form#new_faq').bind 'ajax:complete', (request,response) ->
    $('ul.faqs').append(response.responseText)
    $('.best_in_place').best_in_place()
    update_figures()
  .bind 'ajax:beforeSend', ->
    $(@).find('input').val('')
    $(@).find('textarea').val('')
  
  $('a.remove-faq').live 'ajax:complete', (request,response) ->
    $(@).parent().remove()
    update_figures()
  
  $('.best_in_place').best_in_place()
  
  $('ul.faqs.enable_sort').sortable
    handle: 'span.position'
  .live 'sortupdate', ->
    update_figures()