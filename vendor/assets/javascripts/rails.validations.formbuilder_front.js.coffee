#= require bootstrap

clientSideValidations.formBuilders["ActionView::Helpers::FormBuilder"] =
  add: (element, settings, message) ->
    $(element).tooltip('hide').tooltip(
      fallback: message
      animate: true
      placement: 'above'
      html: 'false'
      offset: 10
      trigger: 'manual'
    ).tooltip('show')
    $(element).addClass('error')
    
  remove: (element, settings) ->
    $(element).tooltip('hide')
    $(element).removeClass('error')