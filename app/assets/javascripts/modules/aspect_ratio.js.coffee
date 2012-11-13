window.resizeWithAspectRatio = (el) ->
  aspectRatio = $(el).data('aspect-ratio')
  currentWidth = $(el).width()
  $(el).css('height',currentWidth*aspectRatio)

window.resizeAllWithAspectRatio = ->
  els = $('[data-aspect-ratio]')
  els.each (i,el) ->
    resizeWithAspectRatio(el)

$ ->
  $(window).on 'resizestop', (e) ->
    resizeAllWithAspectRatio()
      
  .trigger('resize')
  
  $('[data-aspect-ratio]').livequery () ->
    resizeWithAspectRatio(@)
    
  # window.onpopstate (e) ->
  #   console.log "wat"
  #   resizeAllWithAspectRatio()