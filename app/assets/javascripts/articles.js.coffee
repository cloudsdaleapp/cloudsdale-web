#= require helpers/comments

$(document).bind 'articles.load', (e,obj) =>
  makePreview = (source,dest,args) ->
    if args == null or args == NaN
      args.markdown = false
      
    if args.markdown
      converter = new Showdown.converter()
      
    source.live 'keyup', (e) ->
      if args.markdown
        dest.html(converter.makeHtml(source.attr('value')))
      else
        dest.html(source.val())
  
  makePreview $('#article_content'), $('.article-preview-body'),
    markdown: true

  $('form#new_comment').commentForm()
  
  $('#article_content').BetterGrow()
  
  $('#article_tag_tokens').tokenInput "/tags/search.json",
      crossDomain: false
      method: 'POST'
      prePopulate: $("#message_dispatch_group_tokens").data("pre")
      theme: "facebook"
      animateDropdown: false
      tokenValue: 'name'
      preventDuplicates: true
      resultsFormatter: (item) ->
        span = if item.times_referred > 0 then "#{item.times_referred}" else "new"
        "<li>#{item.name}<span>#{span}</span></li>"
  
  
  

    
    
