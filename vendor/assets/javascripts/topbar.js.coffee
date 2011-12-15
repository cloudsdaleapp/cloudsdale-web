window.TopBar = class TopBar
  
  constructor: (args) ->
    @frame = $('.topbar')
    @render()

  render: =>
    @containerExtras = @frame.find('[data-extrascontainer]')
    @containerTriggers = @frame.find('[data-triggerfor]')
    @containerExtras.hide()
    
    @setup()
    @bind()
      
  setup: =>
    console.log "Set up"
    
  bind: =>
    $.each @containerExtras, (k,v) =>
      content_group = $(v).data('extrascontainer')
      trigger = @frame.find("[data-triggerfor=#{content_group}]")
      wrapper = $(v)
      
      trigger.bind 'click', (e) =>
        unless trigger.hasClass('active')
          $(".active[data-triggerfor]").removeClass('active')
          $(".active[data-extrascontainer]").removeClass('active')
          trigger.addClass('active')
          wrapper.addClass('active')
          $("[data-extrascontainer]:not(.active)").slideUp(300)
          wrapper.slideDown(300)
        e.stopImmediatePropagation()


    $(document).bind 'click', (e) =>
      is_inside = false
      $("[data-extrascontainer]").each (k,v) ->
        is_inside = true if $.contains(v, e.target)
      unless is_inside
        $(".active[data-triggerfor]").removeClass('active')
        $(".active[data-extrascontainer]").removeClass('active').slideUp(300)
        
        
      
    
    $('#search-main').bind 'ajax:success', (e,response) ->
      cloud_results = []
      user_results = []
      article_results = []
      $.each $.parseJSON(response), (k,v) ->
        if v._type == 'cloud'
          cloud_results.push v
        else if v._type == 'user'
          user_results.push v

      console.log cloud_results
      console.log user_results
      console.log article_results