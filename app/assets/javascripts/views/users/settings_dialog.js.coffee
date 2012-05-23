class Cloudsdale.Views.UsersSettingsDialog extends Backbone.View
  
  template: JST['users/settings_dialog']
  
  tagName: 'div'
  className: 'modal-container'
  
  initialize: (args) ->
    args = {} unless args
    
    @state = args.state || "general"
    
    @render()
    @bindEvents()
    
    this
  
  render: ->
    $(@el).html(@template(user: session.get('user')))
    this
    

  bindEvents: ->
    session.get('user').on 'change', (user) =>
      @.$('img.user-avatar').attr('src',user.get('avatar').normal)
      @.$('img.user-avatar').text(user.get('name'))
      
    $("body").on "click.tab.data-api", "[data-toggle=\"tab\"], [data-toggle=\"pill\"]", (e) ->
      e.preventDefault()
      $("a[href=#{$(@).attr('href')}]").tab "show"
    
    setTimeout =>
      @.$(".nav.nav-pills a[href=#settings-#{@state}]").tab('show')
    , 0
    
    @.$('.modal').modal().bind 'hide', =>
      @.$('.input-group').tooltip('hide')
      window.setTimeout ->
        $(@el).remove()
      , 500
    
    @.$(':file').change => @submitAvatar()
  
  submitAvatar: ->
    
    @.$('form#avatar-form').append('<div class="loading-content"/>')
    
    $.ajax
      url: "/v1/users/#{session.get('user').id}.json"
      files: @.$(":file")
      iframe: true
      dataType: "application/json"
      complete: (response) =>
        
        @.$(":file").val('')
        
        resp = $.parseJSON(response.responseText)
        
        switch resp.status
          when 200
            session.get('user').set(resp.result)
            @.$('form#avatar-form .loading-content').addClass('load-ok')
            