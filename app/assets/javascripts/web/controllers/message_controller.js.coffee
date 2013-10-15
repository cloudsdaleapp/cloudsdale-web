Cloudsdale.MessageController = Ember.Controller.extend

  needs: ['messages']

  content: null

  text: ( () ->
    text = @content.get('content') || ""

    strategies = [
      [ /&/g, "&amp;" ],
      [ /</g, "&lt;" ],
      [ />/g, "&gt;" ],
      [ /"/g, "&quot;" ],
      [ /\\\\/g, "&#92;" ],
      [ /\s(?=\s)/g, '&nbsp;'],
      [ /(\\r\\n|\\n|\\r)/g, '<br>'],
      [
        # Green Text
        /((^&gt;|<br>&gt;)(.(?!(<br>|$)))+.)/ig,
        "<span style='color: green;'>$1</span>"
      ],
      [
        # Redacted
        /(\[redacted\])/ig,
        "<span style='color: red;'>[REDACTED]</span>"
      ],
      [
        # Italics
        /\*(?!(<br>))(([^\*](?!(<br>|$)))+[^\*])\*/ig,
        "<span style='font-style: italic;'>$1</span>"
      ]
    ]

    for strategy in strategies
      text = text.replace(strategy[0], strategy[1])

    text = text.autoLink({ target: "_blank" })

    return text
  ).property('content.content')

  avatar: ( () ->
    @content.get('author').get('avatar') if @content.get('author')
  ).property('content.author.avatar')

  name: ( () ->
    @content.get('author').get('displayName') if @content.get('author')
  ).property('content.author.displayName')

  handle: ( () ->
    @content.get('author').get('username') if @content.get('author')
  ).property('content.author.username')

  createdAt: ( () ->
    console.log @content.get('createdAt')
    @content.get('createdAt')
  ).property('content.createdAt')

  updatedAt: ( () ->
    @content.get('updatedAt')
  ).property('content.updatedAt')

  timestamp: ( () ->
    @content.get('timestamp')
  ).property('content.timestamp')

  previousModel: ( () ->
    @get('controllers.messages').before(@get('model'))
  ).property('controllers.messages.arrangedContent.@each')

  nextModel: ( () ->
    @get('controllers.messages').after(@get('model'))
  ).property('controllers.messages.arrangedContent.@each')

  hasSameAuthorAsPrevious: ( () ->
    if @get('previousModel') &&  @get('model')
      cur  = @get('model').get('author')
      prev = @get('previousModel').get('author')
      return cur.id == prev.id
    return false
  ).property('previousModel')

  hasSameAuthorAsNext: ( () ->
    if @get('nextModel') &&  @get('model')
      cur  = @get('model').get('author')
      prev = @get('nextModel').get('author')
      return cur.id == prev.id
    return false
  ).property('nextModel')

  messageStatus: ( () ->
    return if @get('model').get('isNew') then 'Sending' else @get('updatedAt').toString('hh:mm:ss')
  ).property('content.isNew', 'content.updatedAt')

  isEdited: ( () ->
    @get('content.createdAt').getTime() != @get('content.updatedAt').getTime()
  ).property('content.createdAt', 'content.updatedAt')
