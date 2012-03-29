$(document).bind 'index_explore.load', (e,obj) =>
  $("#featured-clouds").carousel()
  $("[rel='popover']").popover
    title: 'lolo'
    placement: 'top'
    trigger: 'hover'