$ ->
  
  $('a[data-toggle="tab"]').live 'shown', (e) ->
    tab_id = e.target.href.match(/(\#.+)[\?\&\/]?/i)[1]
    window.history.pushState({tab_id:tab_id},document.title,e.target.href)
  
  window.onpopstate = (e) ->
    if e.state
      $("a[data-toggle='tab'][href='#{e.state.tab_id}']").tab('show')
  
  $(document).bind 'application.load', =>
    tab_id = window.document.URL.match(/(\#.+)[\?\&\/]?/i)
    if tab_id
      $("a[data-toggle='tab'][href='#{tab_id[1]}']").tab('show')
    else
      $("a[data-toggle='tab']:first").tab('show')