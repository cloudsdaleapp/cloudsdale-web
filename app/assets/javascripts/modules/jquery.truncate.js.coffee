jQuery.fn.fitsTruncationSpecs = (content,maxHeight,settings) ->
  
  old = if settings.html then @html() else @text()
  
  truncateWrapper = @html("<span class='jquery-truncate' style='display: block; float: none;'></span>").find('.jquery-truncate')
  
  if settings.html
    truncateWrapper.html(content)
  else
    truncateWrapper.text(content)
  
  itFits = truncateWrapper.height() <= maxHeight
    
  if settings.html then @html(old) else @text(old)
  
  return itFits
    
jQuery.fn.performTruncation = (text,width,lheight,maxHeight,settings) ->
  
  @text("")
  
  characters = text.split("")
  
  hasNotYetExceededSpecs = true
  workingText = ""
  currentText = workingText
  
  for character in characters
    do (character) =>
      if hasNotYetExceededSpecs
        workingText += character
        textToTest = workingText + settings.omission
        if @fitsTruncationSpecs(textToTest,maxHeight,settings)
          currentText = textToTest
        else
          hasNotYetExceededSpecs = false
  
  if settings.html
    @html(currentText)
  else
    @text(currentText)
        
        
        
jQuery.fn.truncate = (options) ->
  
  options ||= {}
  
  settings =
    omission: '...'
    rows: 1
    html: false
  
  jQuery.extend(settings, options)
    
  $.each @, (i,el) ->
    
    # Set up some current state variables
    text = $(el).text()
    width = $(el).width()
    lheight = if $(el).css('line-height') then parseInt($(el).css('line-height').match(/\d+/)[0]) else 0
    
    maxHeight = lheight * settings.rows
    
    $(el).performTruncation(text,width,lheight,maxHeight,settings) unless $(el).fitsTruncationSpecs(text,maxHeight,settings)