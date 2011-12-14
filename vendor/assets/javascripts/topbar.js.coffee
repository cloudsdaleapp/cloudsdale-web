window.TopBar = class TopBar
  
  constructor: (args) ->
    
    @render()

  render: =>
    console.log "Rendered"
    @setup()
    @bind()
    
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
      
  setup: =>
    console.log "Set up"
    
  bind: =>
    console.log "Bound"