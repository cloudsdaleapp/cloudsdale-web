class Cloudsdale.Views.CloudsSettingsDialog extends Backbone.View
  
  template: JST['clouds/settings_dialog']
  
  tagName: 'div'
  className: 'modal-container'

  events:
    'click .remove-avatar' : "removeAvatar"
  
  initialize: (args) ->
    args = {} unless args
    
    @state = args.state || "general"
    @cloud = args.cloud
    
    @render()
    @bindEvents()
    
    this
  
  render: ->
    $(@el).html(@template(cloud: @cloud))
    this
    

  bindEvents: ->
    
    @cloud.on 'change', (cloud) =>
      @.$('img.cloud-avatar').attr('src',cloud.get('avatar').normal)
      @.$('h2.cloud-name').text(cloud.get('name'))
    
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
    
    @.$(':text,:password,textarea').on 'change', (event) ->
      unless $(@).data('preventAjax') == true
        submitData = {}
        submitData[@name] = @value
        $.event.trigger 'change:field:cloud', { element: @, submitData: submitData }
          
    $(@el).bind 'change:field:cloud', (event,payload) =>
      submitData = payload.submitData
      elem = payload.element
      @clearFieldErrors(@.$(elem))
      
      @.$(elem).parent().addClass('loading-controls')
      
      @saveCloud(submitData,
        success: (cloud,response) =>
          @.$(elem).parent().removeClass('loading-controls')
        error: (cloud,response) =>
          @displayFieldErrorsFromResponse(response)
          @.$(elem).parent().removeClass('loading-controls')
      )
  
  saveCloud: (attr,options) ->
    attr ||= {}
    options ||= {}
    options.wait = true
    @cloud.save(attr,options)
  
  removeAvatar: (event) =>
    unless @.$(event.target).attr('disabled') == 'disabled' 
      @.$(event.target).attr('disabled','disabled')
      @cloud.removeAvatar
        success: =>
          @.$(event.target).attr('disabled',null)
          
    false
  
  submitAvatar: ->
    
    @.$('form#avatar-form').append('<div class="loading-content"/>')
    
    $.ajax
      url: "/v1/clouds/#{@cloud.id}.json"
      files: @.$(":file")
      iframe: true
      dataType: "application/json"
      complete: (response) =>
        @.$(":file").val('')
        @.$('form#avatar-form > .loading-content').remove()
        resp = $.parseJSON(response.responseText)
        console.log resp
        switch resp.status
          when 200
            @cloud.set(resp.result)
            @.$('form#avatar-form .loading-content').addClass('load-ok')
  
  displayFieldErrorsFromResponse: (response) ->
    errors = $.parseJSON(response.responseText).errors
    $.each errors, (id,error) =>
      if error.type == "field"
        field = $("[name=#{error.ref_node}]")
        controls = field.parent().parent()
        
        controls.addClass('error')
        field.after("<span class='help-inline field-error-message'>#{error.message}</span>")
  
  clearFieldErrors: (field) ->
    controls = field.parent().parent()
    controls.removeClass('error')
    controls.find("span.help-inline.field-error-message").remove()
    
