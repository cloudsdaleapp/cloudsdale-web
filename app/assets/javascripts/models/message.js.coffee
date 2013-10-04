class Cloudsdale.Models.Message extends Backbone.Model

  sync: railsRestSync
  type: 'message'

  initialize: () ->

  url: -> "/v1/#{@get('topic_type')}s/#{@get('topic_id')}/chat/messages"

  timestamp: -> new Date(@get('timestamp'))

  toJSON: ->
    {
      message: { content: @get("content"), client_id: session.get('client_id'), device: @get('device') }
    }

  selfReference: -> if @get('content').match(/^\/me/i) then true else false

  drops: -> new Cloudsdale.Collections.Drops(@get('drops'))

  user: (args) ->
    author = null

    if @get('author')
      author = @get('author')
      fetch = false
    else if @get('author_id')
      author = { id: @get('author_id') }
      fetch = true

    if author
      return session.get('users').findOrInitialize author,
        fetch: fetch
    else
      author = new Cloudsdale.Models.User({})
      session.get('users').add(author)
      return author

  topic: (args) ->
    return session.get(@get('topic_type') + 's').findOrInitialize { id: @get('topic_id') },
      fetch: false

