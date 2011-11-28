do ($ = jQuery) ->
  class AvatarUploadForm
    constructor: (@wrapper,args = {}) ->
      @fileSrc =    if args.fileSrc     then @wrapper.find(args.fileSrc) else @wrapper.find('input[type=file]')
      @fileRadio =  if args.fileRadio   then @wrapper.find(args.fileRadio) else @wrapper.find("input[type='radio'][value='file']")
      @urlSrc =    if args.fileSrc     then @wrapper.find(args.fileSrc) else @wrapper.find('input[type=text]')
      @urlRadio =  if args.fileRadio   then @wrapper.find(args.fileRadio) else @wrapper.find("input[type='radio'][value='url']")
      @imgPreview = if args.imgPreview  then @wrapper.find(args.imgPreview) else @wrapper.find('img.preview')
      @bind()
    
    bind: () ->
      @urlRadio.change () =>
        @enableUrl()

      @fileRadio.change () =>
        
        @enableFile()

      @urlSrc.bind 'mousedown', =>
        
        @urlRadio.attr('checked','true')
        @enableUrl()
        
      .bind 'keydown', (e) =>
        setTimeout (=>
          @updatePreview(@urlSrc.val())
        ), 100
      
      @fileSrc.live 'mousedown', =>
        @fileRadio.attr('checked','true')
        @enableFile()
        
      @imgPreview.bind 'onerror', () =>
        false
  
    enableUrl: () =>
      @urlRadio.parent().addClass('active')
      @fileRadio.parent().removeClass('active')
      @urlSrc.removeClass('disabled')
      fileSrcId = @fileSrc.attr('id')
      fileSrcName = @fileSrc.attr('name')
      @fileSrc.replaceWith("<input data-validate='true' id='#{fileSrcId}' name='#{fileSrcName}' type='file' class='disabled'/>")
      @fileSrc =  @wrapper.find("input[type=file][id='#{fileSrcId}']")
      
    enableFile: () =>
      @fileRadio.parent().addClass('active')
      @urlRadio.parent().removeClass('active')
      @urlSrc.addClass('disabled').val('')
      @fileSrc.removeClass('disabled')
    
    updatePreview: (src) =>
      try
        @imgPreview.attr('src',src)
      catch error
        console.log error
        
  $.fn.avatarUpload = ->
    new AvatarUploadForm(@,arguments[0])