#= require helpers/comments

$(document).bind 'new_articles.load edit_articles.load', (e,obj) =>

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
  
  $('.tabs').tabs("asd")
  $("#.tabs a").bind 'change', (e) ->
    targetContent = $($(e.target).attr('href'))
    if $("#preview")[0] == targetContent[0]
      raw_markdown = $('#modify textarea').val()
      preview = targetContent.find('article')
      if raw_markdown.length > 0
        preview.html("<h3>Loading...</h3>")
        $.post "/articles/parse",
          { markdown:raw_markdown },
          (data) ->
            preview.html(data)
        .error ->
          preview.html("<h3>Error...</h3>")
      else
        preview.html("<h3>Nothing to Render...</h3>")
        
    
  
  

    
    
