clientSideValidations.formBuilders["ActionView::Helpers::FormBuilder"] =
  add: (element, settings, message) ->
    $(element).parent().find("span.help-inline").remove()
    $(element).after("<span class=help-inline>#{message}</span>")
    $(element).parent().parent().addClass('error')
    
  remove: (element, settings) ->
    $(element).parent().find("span.help-inline").remove()
    $(element).parent().parent().removeClass('error')