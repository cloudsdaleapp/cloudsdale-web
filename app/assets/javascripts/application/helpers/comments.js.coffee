do ($ = jQuery) ->
  class CommentForm
    constructor: (@form,args = {}) ->
      @counter = if args.count_handler then @form.find(args.count_handler) else @form.find('.character-counter')
      @input = if args.input then @form.find(args.input) else @form.find('textarea#comment_content')
      @submitter = if args.submitter then @form.find(args.submitter) else @form.find('input[type=submit]')
      @config()
      @bind()
    config: =>
      @input_max_len = 300
    bind: =>
      @input.BetterGrow
        initial_height: 12
        do_not_enter: false
      .bind 'keyup', (e) =>
        cur_len = @input.val().length
        @counter.html(cur_len)
        if cur_len > @input_max_len
          @form.addClass('invalid')
          @submitter.prop('disabled',true)
        else
          @form.removeClass('invalid')
          @submitter.prop('disabled',false)
      .bind 'focus', =>
        @form.addClass('active')
        
      @form.bind 'click', (e) =>
        e.stopPropagation()
      $('html').bind 'click', (e) =>
        @form.removeClass('active')

        
  $.fn.commentForm = ->
    new CommentForm(@,arguments[0])