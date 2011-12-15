window.TopBar = class TopBar
  
  constructor: (args) ->
    @frame = $('.topbar')
    @render()

  render: =>
    @searchForm = $('#search-main')
    @searchInput = @searchForm.find('input[type=text]')
    
    @searchCloudWrapper = @frame.find("[data-searchresultcontainer=clouds]")  # Clouds  #
    @searchEntryWrapper = @frame.find("[data-searchresultcontainer=entries]") # Entries #
    @searchUserWrapper = @frame.find("[data-searchresultcontainer=users]")    # Users   #
    
    @containerExtras = @frame.find('[data-extrascontainer]')
    @containerTriggers = @frame.find('[data-triggerfor]')
    @containerExtras.hide()
    
    @setup()
    @bind()
      
  setup: =>
    console.log "Set up"
    
  bind: =>
    @searchForm.bind 'ajax:complete', (e,response) =>
      resp = $.parseJSON(response.responseText)
      @renderSearchResult(@searchCloudWrapper,resp.clouds)
      @renderSearchResult(@searchEntryWrapper,resp.entries)
      @renderSearchResult(@searchUserWrapper,resp.users)
      
    .bind 'submit', (e) =>
      (@searchInput.attr('value').match(/^\s*$/) == null) and (@searchInput.val.length > 0)
        
    $.each @containerExtras, (k,v) =>
      content_group = $(v).data('extrascontainer')
      trigger = @frame.find("[data-triggerfor=#{content_group}]")
      wrapper = $(v)
      
      trigger.bind 'click', (e) =>
        unless trigger.hasClass('active')
          $(".active[data-triggerfor]").removeClass('active')
          $(".active[data-extrascontainer]").removeClass('active')
          $("[data-extrascontainer]:not(.active)").slideUp(300)
          trigger.addClass('active')
          wrapper.slideDown(300).addClass('active')
        e.stopImmediatePropagation()


    $(document).bind 'click', (e) =>
      is_inside = false
      $("[data-extrascontainer]").each (k,v) ->
        is_inside = true if $.contains(v, e.target)
      unless is_inside
        $(".active[data-triggerfor]").removeClass('active')
        $(".active[data-extrascontainer]").removeClass('active').slideUp(300)

  
  renderSearchResult: (wrapper,results) =>
    moreTrigger = wrapper.find("nav > a")
    resultInfo = wrapper.find("span.metadata")
    resultContainer = wrapper.find('ul.results')
    resultContainer.html("")
    $.each results, (k,v) =>
      resultContainer.append(
        "<li class='result'>
          <a href='/#{v._index}/#{v.id}'>
            <img src='#{v.avatar_versions.mini}'/>
            #{v.name}
          </a>
        </li>"
      )
      return false if (k >= 2)