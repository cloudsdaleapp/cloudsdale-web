#= require bootstrap

clientSideValidations.formBuilders["ActionView::Helpers::FormBuilder"] =
  add: (element, settings, message) ->
    $(element).twipsy('hide').twipsy(
      fallback: message
      animate: true
      placement: 'above'
      html: 'false'
      offset: 10
      trigger: 'manual'
    ).twipsy('show')
    $(element).addClass('error')
    
  remove: (element, settings) ->
    $(element).twipsy('hide')
    $(element).removeClass('error')