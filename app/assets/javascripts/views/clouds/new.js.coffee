class Cloudsdale.Views.CloudsNew extends Backbone.View
  
  template: JST['clouds/new']
  className: 'explore-create-wrapper'
  
  events:
    'click a.explore-create-start' : 'startCreation'
    'click a.explore-create-cancel' : 'cancelCreation'
    'click a.explore-create-login' : 'requestLogin'
    'submit form.explore-create-form' : 'saveCloud'
    'keyup input[type=text]' : 'clearFieldErrors'
    
  
  initialize: (args) ->
    
    args = {} unless args
    
    @render()
    @bindEvents()
    
  render: ->
    $(@el).html(@template(view: @))
    this
    
  bindEvents: ->
    session.get('user').on 'change', (user) => @render()
  
  startCreation: ->
    @.$('.explore-create-inner').addClass('active')
    false
  
  cancelCreation: ->
    @.$('.explore-create-inner').removeClass('active')
    false
  
  requestLogin: ->
    view = new Cloudsdale.Views.SessionsDialog(state: 'login').el
    if $('.modal-container').length > 0 then $('.modal-container').replaceWith(view) else $('body').append(view)
  
  saveCloud: (event) ->
    event.preventDefault()
    
    @model = new Cloudsdale.Models.Cloud()
    
    @model.set 'name', @.$('#new_cloud_name').val()
    @model.save {},
      success: (cloud) =>
        @render()
        session.get('clouds').add(cloud)
        Backbone.history.navigate("/clouds/#{cloud.id}",true)
        false
      error: (model,xhr,resp) =>
        @displayFieldErrorsFromResponse(xhr)
        
    false
  
  displayFieldErrorsFromResponse: (xhr) ->
    errors = $.parseJSON(xhr.responseText).errors
    $.each errors, (id,error) =>
      if error.type == "field"
        field = $("[name=#{error.ref_node}]")
        controls = field.parent().parent()
        
        controls.addClass('error')
        field.after("<span class='help-block field-error-message'>#{error.message}</span>")
  
  clearFieldErrors: (event) ->
    controls = @.$(event.target).parent().parent()
    controls.removeClass('error')
    controls.find("span.help-block.field-error-message").remove()